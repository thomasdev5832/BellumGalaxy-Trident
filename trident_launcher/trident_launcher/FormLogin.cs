using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using tridentApi;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ListView;

namespace trident_launcher
{
    public partial class FormLogin : Form
    {
        private bool _logged;
        public FormLogin()
        {
            InitializeComponent();
        }
        private async Task<string> verifyLoginAsync(string username, string password)
        {
            ApiClient apiClient = new ApiClient();

            string loginSuccess = await apiClient.LoginAsync(username, password);
            Console.WriteLine(loginSuccess);
            if (!string.IsNullOrEmpty(loginSuccess))
                return loginSuccess;
            else
            {
                return null;
            }
        }
        private void FormLogin_Load(object sender, EventArgs e)
        {

        }

        private async void login_ClickAsync(object sender, EventArgs e)
        {
            string email = emailText.Text;
            string password = passwordText.Text;
            if (String.IsNullOrEmpty(email) || String.IsNullOrEmpty(password))
            {
                MessageBox.Show("Por favor insira seu email e sua senha", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            string token = await verifyLoginAsync(email, password);
            

            if (string.IsNullOrEmpty(token))
            {
                _logged = false;
                MessageBox.Show("Usu�rio ou senha inv�lidos", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                emailText.Text = "";
                passwordText.Text = "";
                return;
            }

            this.Close();
            Thread t = new Thread(() => Application.Run(new Trident(token)));
            t.Start();

        }

        private void loginBox_Enter(object sender, EventArgs e)
        {

        }

        private void Email_Click(object sender, EventArgs e)
        {

        }

        private void password_Click(object sender, EventArgs e)
        {

        }

        private void loginBox_Click(object sender, EventArgs e)
        {

        }

        private void emailText_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
