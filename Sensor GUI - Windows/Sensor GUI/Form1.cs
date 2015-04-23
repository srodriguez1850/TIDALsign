using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sensor_GUI
{
    public partial class Form1 : Form
    {
        HandSensor sensor;
        Arduino arduino;
        Timer myTimer = new Timer();

        public Form1(ref Arduino a)
        {
            InitializeComponent();
            arduino = a;
            myTimer.Interval = 200;
            myTimer.Tick += new EventHandler(myTimer_Tick);
        }

        private void myTimer_Tick(object sender, EventArgs e)
        {
            label3.Text = Convert.ToString(arduino.getAnalogRead());
            myTimer.Stop();
            myTimer.Start();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            // Code here to send signal to Arduino to close its port
            Application.Exit();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            arduino.SetComPort();
            if (arduino.portStatus)
            {
                button2.Enabled = false;
                this.Controls.Add(button2);
                label2.Text = "Arduino in " + arduino.comPortName;
                myTimer.Start();
            }
        }

        private void label3_Click(object sender, EventArgs e)
        {
            label3.Text = Convert.ToString(arduino.getAnalogRead());
        }

        public class HandSensor
        {
            // Ranges to calibrate the hand sensor
            int rangeMin;
            int rangeMax;

            // Values to assign to the hand sensor
            int hsThumb;
            int hsIndex;
            int hsMiddle;
            int hsRing;
            int hsPinky;
        }
    }
}
