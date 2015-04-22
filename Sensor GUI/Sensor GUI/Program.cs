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
            arduino.SetComPort();

            if (arduino.portStatus)
            {
                Application.Run(new Form1(arduino));
            }
            else
            {
                MessageBox.Show("Arduino not detected. Please ensure an Arduino is connected.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
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

                int intReturnASCII = 0;

                // Test port, open and send handshake
                currentPort.Open();
                currentPort.Write(buffer, 0, 3);
                Thread.Sleep(3000);

                int count = currentPort.BytesToRead;
                string returnMessage = "";

                // Parse response
                while (count > 0)
                {
                    intReturnASCII = currentPort.ReadByte();
                    returnMessage += Convert.ToChar(intReturnASCII);
                    count--;
                }

                // Close port
                currentPort.Close();

                // Check if Arduino responded
                if (returnMessage.Contains("HELLO FROM ARDUINO"))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch
            {
                return false;
            }
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
                return currentPort.PortName;
            }
        }
    }
}
