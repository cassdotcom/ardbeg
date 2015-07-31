using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Collections;
using System.Windows;
using System.Windows.Threading;
using System.Threading;
using Forms = System.Windows.Forms;

namespace WPFRunspace
{

    public static class PSHelper
    {


        public static BackgroundWorker CreateBGWorker()
        {
            return new BackgroundWorker();
        }

        
        public static BackgroundWorker CreateBGWorker(FrameworkElement frameworkElement)
        {
            return new BackgroundWorker(frameworkElement);
        }

        public static BackgroundWorker CreateBGWorker(Forms.Control control)
        {
            return new BackgroundWorker(control);
        }



        public static PSParameter NewPSParameter(string name, object value)
        {
            return new PSParameter(name, value);
        }


    }

    [Serializable]
    public class PSParameter
    {
        public string Name { get; set; }

        public object Value { get; set; }

        public PSParameter()
        {

        }

        public PSParameter(string Name, object Value)
        {
            this.Name = Name;
            this.Value = Value;
        }

        

        public override string ToString()
        {
            return Name + ": " + Value.ToString();
        }
    }




    public class BackgroundWorker
    {
        private enum WorkerWindowType
        {
            None = 0,
            WPF,
            Form
        }

        private WorkerWindowType windowType  = WorkerWindowType.None;
        public BackgroundWorker()
        {
            
        }

        public BackgroundWorker(Forms.Control control)
            
        {
            this.control = control;
            windowType  = WorkerWindowType.Form;
        }

        public BackgroundWorker(FrameworkElement frameworkElement)
        {
            this.frameworkElement = frameworkElement;
            windowType = WorkerWindowType.WPF;
        }

        private FrameworkElement frameworkElement = null;

        

        public FrameworkElement FrameworkElement
        {
            get
            {
                return frameworkElement;
            }

        }

        

        private Forms.Control control = null;

        public Forms.Control Control
        {
            get
            {
                return control;
            }

        }

        private Pipeline pipeline = null;

        public void Stop()
        {
            pipeline.StopAsync();
            
        }
  
        private int next = -1;

        public PSObject GetReadyData()
        {
              next++; 
              return results[next];

        }
        public void Reset()
        {
            next = -1;
            results.Clear();
            errors.Clear();
        }

        private PSDataCollection<PSObject> results = new PSDataCollection<PSObject>();


        public PSObject[] Results
        {
            get { return results.ToArray(); }
            
        }

        private Action dataReadyAction;
        private object lockDR = new object(); 

        public Action DataReadyAction
        {
            set
            {
                lock (lockDR)
                {
                    dataReadyAction = value;
                }
            }
        }

        private Action stateChangedAction;

        private object lockSC = new object(); 
        
        
        
        public Action StateChangedAction
        {
            set
            {
                lock (lockSC)
                {
                    stateChangedAction = value;
                }
            }
        }

        private PSDataCollection<object> errors = new PSDataCollection<object>();

        public object[] Errors
        {
            get { return errors.ToArray(); }
            
        }

        private PipelineStateInfo stateInfo;
        private object lockState = new object(); 
        public PipelineStateInfo StateInfo
        {
            get {
                lock (lockState)
                {
                    return stateInfo;
                }
            }
            
        }

        private PSParameter[] parameters = new PSParameter[]{};

        public PSParameter[] Parameters
        {
            get { return parameters; }
            set { parameters = value; }
        }

        private ScriptBlock scriptBlock;

        public ScriptBlock ScriptBlock
        {
            get { return scriptBlock; }
            set { scriptBlock = value; }
        }



        public void Invoke()
        {
            Invoke(ScriptBlock);
        }

        public void Invoke(ScriptBlock scriptBlock)
        {
            
            Invoke(scriptBlock, Parameters);
        }


        public void Invoke(ScriptBlock scriptBlock, PSParameter[] parameters)
        {
            
            Runspace runspace = RunspaceFactory.CreateRunspace();
            runspace.ApartmentState = System.Threading.ApartmentState.STA;
            runspace.ThreadOptions = PSThreadOptions.ReuseThread;
            runspace.Open();

            foreach (PSParameter arg in parameters)
            {
                runspace.SessionStateProxy.SetVariable(arg.Name, arg.Value);

            }
            
            try
            {
                pipeline = runspace.CreatePipeline(scriptBlock.ToString());
            }
            catch (Exception ex)
            {
                throw new NullReferenceException("Either no scriptblock property has been set on the BackgroundWorker or the scriptblock is not valid.", ex);
            }
            
            
            switch (windowType)
            {
                case WorkerWindowType.WPF:
                    executeAction += ExecuteWPFAction;
                    break;
                case WorkerWindowType.Form:
                    executeAction += ExecuteFrmAction;
                    break;
                default:
                    executeAction += ExecuteConsoleAction;
                    break;
            }

            pipeline.Output.DataReady += HandleDataReady;
            pipeline.Error.DataReady += HandleDataReady;
            pipeline.StateChanged += new EventHandler<PipelineStateEventArgs>(Handle_StateChanged);
            
            // Start the pipeline
            pipeline.InvokeAsync();
            pipeline.Input.Close();
           
            
        }

        

        private void Handle_StateChanged(object sender, PipelineStateEventArgs e)
        {
            Pipeline pipeline = sender as Pipeline;
            lock (lockState)
            {
                stateInfo = pipeline.PipelineStateInfo;
            }
            executeAction(stateChangedAction);
            if (pipeline.PipelineStateInfo.State > PipelineState.Stopping)
            {
                 
                 pipeline.Dispose();
            }
        }

        //private void HandleFrm_StateChanged(object sender, PipelineStateEventArgs e)
        //{
        //    Pipeline pipeline = sender as Pipeline;
        //    lock (lockState)
        //    {
        //        stateInfo = pipeline.PipelineStateInfo;
        //    }
        //    ExecuteFrmAction(stateChangedAction);
        //    if (pipeline.PipelineStateInfo.State > PipelineState.Stopping)
        //    {

        //        pipeline.Dispose();
        //    }
        //}


        private void HandleDataReady(object sender, EventArgs e)
        {

            PipelineReader<PSObject> output = sender as PipelineReader<PSObject>;

            if (output != null)
            {
                // Accumulate results
                while (output.Count > 0)
                {

                    PSObject result =  output.Read();
                    results.Add(result);
                    executeAction(dataReadyAction);
                }
                
                return;
            }

            PipelineReader<object> error = sender as PipelineReader<object>;
            

            if (error != null)
            {
                while (error.Count > 0)
                {
                    object err = error.Read();
                    errors.Add(err);
                    executeAction(stateChangedAction);
                }
                
                return;
            }

        }


        //private void HandleFrmDataReady(object sender, EventArgs e)
        //{

        //    PipelineReader<PSObject> output = sender as PipelineReader<PSObject>;

        //    if (output != null)
        //    {
        //        // Accumulate results
        //        while (output.Count > 0)
        //        {

        //            PSObject result = output.Read();
        //            results.Add(result);
        //            ExecuteFrmAction(dataReadyAction);
        //        }

        //        return;
        //    }

        //    PipelineReader<object> error = sender as PipelineReader<object>;


        //    if (error != null)
        //    {
        //        while (error.Count > 0)
        //        {
        //            object err = error.Read();
        //            errors.Add(err);
        //            ExecuteFrmAction(stateChangedAction);
        //        }

        //        return;
        //    }

        //}

        private Action<Action> executeAction;

        private void ExecuteWPFAction(Action action)
        {
            if (action == null)
            {

                return;
            };

            if (FrameworkElement == null)
            {
                throw new ApplicationException("'FrameworkElement' is null or invalid?");
            }

            FrameworkElement.Dispatcher.Invoke(action, DispatcherPriority.Normal);


        }



        private void ExecuteFrmAction(Action action)
        {
            if (action == null)
            {

                return;
            };

            if (Control == null)
            {
                throw new ApplicationException("Form or control is either null or invalid?");
            }

            Control.Invoke(action);
        }

        private void ExecuteConsoleAction(Action action)
        {
            if (action == null)
            {

                return;
            };

           action.Invoke();


        }

    }
}

