using System.Diagnostics;
using trident_launcher_pooling;
using tridentCore;
using trident_launcher_pooling;

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
           
            PoolingVerifyGames tridentPooling = new PoolingVerifyGames();
            Thread pooling = new Thread(() => tridentPooling.initPooling());
            pooling.Start();
            Button buttonStop = new Button();

           
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
