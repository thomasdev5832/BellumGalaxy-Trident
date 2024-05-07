using System.Diagnostics;
using tridentCore;

namespace trident_launcher
{
    public partial class Trident : Form
    {

        public Trident()
        {
            InitializeComponent();

        }

        private void Form1_Load(object sender, EventArgs e)
        {
        }

        private void TextBox_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }


        private void initTrident_Click(object sender, EventArgs e)
        {
            Process[] processes = Process.GetProcesses();

            TridentCore tridentCore = new TridentCore();
            string retorno = tridentCore.manipulateProcess(processes);
        }

        private void menuGroup_Enter(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged_1(object sender, EventArgs e)
        {

        }

        private void LogonButton_Click(object sender, EventArgs e)
        {
            this.Close();
            Thread t = new Thread(() => Application.Run(new FormLogin()));
            t.Start();

        }
    }
}
