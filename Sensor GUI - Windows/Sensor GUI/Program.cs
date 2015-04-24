using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.IO.Ports;

namespace Sensor_GUI
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // See if this counts as a variable that can be passed as reference
            Arduino arduino = new Arduino();

            Application.Run(new Form1(ref arduino));
        }
    }
    public class Arduino
    {
        SerialPort currentPort;
        bool portFound;

        public void SetComPort()
        {
            try
            {
                string[] ports = SerialPort.GetPortNames();

                if (ports.Length == 0)
                {
                    portFound = false;
                }

                foreach (string port in ports)
                {
                    currentPort = new SerialPort(port, 19200);

                    if (DetectArduino())
                    {
                        portFound = true;
                        break;
                    }
                    else
                    {
                        portFound = false;
                    }
                }
            }
            catch (Exception e)
            {
                // Extraneous circumstances
            }
        }
        private bool DetectArduino()
        {
            try
            {
                // Attempt handshake with Arduino
                byte[] buffer = new byte[3];
                buffer[0] = Convert.ToByte('H');
                buffer[1] = Convert.ToByte('I');
                buffer[2] = Convert.ToByte('!');

                /*
                byte[] b1 = new byte[1];
                byte[] b2 = new byte[1];
                byte[] b3 = new byte[1];
                b1[0] = Convert.ToByte('H');
                b2[0] = Convert.ToByte('I');
                b3[0] = Convert.ToByte('!');
                */

                // Test port, open and send handshake
                currentPort.Open();
                currentPort.Write(buffer, 0, 3);
                Thread.Sleep(100);

                // Parse response
                string returnMessage = Convert.ToString(currentPort.ReadExisting());

                // Check if Arduino responded
                if (returnMessage.Contains("HELLO FROM ARDUINO"))
                {
                    return true;
                }
                else
                {
                    // Close port if no response
                    currentPort.Close();
                    return false;
                }
            }
            catch
            {
                return false;
            }
        }
        public int getAnalogRead()
        {
            byte[] command = new byte[3];
            command[0] = Convert.ToByte('R');   // Read Pin
            command[1] = Convert.ToByte('A');   // Analog Pin
            command[2] = Convert.ToByte('0');   // Pin 0

            currentPort.Write(command, 0, 3);
            Thread.Sleep(100);

            return Convert.ToInt16(currentPort.ReadExisting());
        }
        public bool portStatus
        {
            get
            {
                return portFound;
            }
        }
        public string comPortName
        {
            get
            {
                try
                {
                    return currentPort.PortName;
                }
                catch
                {
                    return "NULL";
                }
            }
        }
    }
}
