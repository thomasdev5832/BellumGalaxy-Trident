using System.Diagnostics;
using trident_launcher_pooling;
using tridentApi;
using trident_interfaces;
using tridentCore;
using System.Windows.Forms;
using System.Xml;

namespace trident_launcher
{
    public partial class Trident : Form
    {
        ApiConnection _connectApi = new ApiConnection();
        List<Games> games;
        Thread pooling;
        private string nameProcess = "trident_launcher";
        public Trident()
        {
            InitializeComponent();

        }

        public void GameCard(string image, string name, bool status)
        {

         PictureBox imageBox = new PictureBox();
         Label nomeGameBox =  new Label();
         Label statusLabel = new Label();
        // Configurando o tamanho do cartão do jogo
            Size = new Size(200, 150);

            // Configurando a imagem
            imageBox = new PictureBox();
            //pictureBox.Image = image;
            imageBox.SizeMode = PictureBoxSizeMode.Zoom;
            imageBox.Size = new Size(100, 100);
            imageBox.Location = new Point(50, 10);
            Controls.Add(imageBox);

            // Configurando o nome do jogo
            nomeGameBox = new Label();
            nomeGameBox.Text = name;
            nomeGameBox.AutoSize = false;
            nomeGameBox.TextAlign = ContentAlignment.MiddleCenter;
            nomeGameBox.Size = new Size(200, 20);
            nomeGameBox.Location = new Point(0, 120);
            Controls.Add(nomeGameBox);

            // Configurando o status do jogo
            statusLabel = new Label();
            statusLabel.Text = status ? "Bloqueado" : "Liberado";
            statusLabel.AutoSize = false;
            statusLabel.TextAlign = ContentAlignment.MiddleCenter;
            statusLabel.Size = new Size(200, 20);
            statusLabel.Location = new Point(0, 140);
            Controls.Add(statusLabel);
        }
        private void CreateGameList()
        {
            games = _connectApi.getGames();

            foreach (Games game in games)
            {
                GameCard("", game.Name, game.Isbloked);
            }
        }
        private void Form1_Load(object sender, EventArgs e)
        {

            PoolingVerifyGames tridentPooling = new PoolingVerifyGames();
            pooling = new Thread(() => tridentPooling.initPooling());
            pooling.Name = nameProcess;
            pooling.Start();  
    }

        private void TextBox_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }


        private void initTrident_Click(object sender, EventArgs e)
        {



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
           
            // Encerrando todos os processos com o mesmo nome

            //Thread t = new Thread(() => Application.Run(new FormLogin()));
            //t.Start();

        }

        private void menuGroup_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged_1(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged_2(object sender, EventArgs e)
        {

        }

    }
}
