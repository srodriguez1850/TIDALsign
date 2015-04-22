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
        Arduino arduino;

        public Form1(Arduino a)
        {
            InitializeComponent();
            arduino = a;
            label2.Text = "Arduino in " + arduino.comPortName;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            // Code here to send signal to Arduino to close it's port
            Application.Exit();
        }
    }
}
