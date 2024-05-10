using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace trident_launcher
{
    public partial class FormLogin : Form
    {
        private bool _logged;
        public FormLogin()
        {
            InitializeComponent();
        }
        private bool verifyLogin(string username, string password)
        {
            const string UsuarioCorreto = "admin@trident.com";
            const string SenhaCorreta = "admin";
            if (UsuarioCorreto == username && SenhaCorreta == password)
            {
                return true;
            }
            return false;
        }
        private void FormLogin_Load(object sender, EventArgs e)
        {

        }

        private void login_Click(object sender, EventArgs e)
        {
            string email = emailText.Text;
            string password = passwordText.Text;
            if (String.IsNullOrEmpty(email) || String.IsNullOrEmpty(password))
            {
                MessageBox.Show("Por favor insira seu email e sua senha", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            _logged = verifyLogin(email, password);

            if (!_logged)
            {
                MessageBox.Show("Usu�rio ou senha inv�lidos", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                emailText.Text = "";
                passwordText.Text = "";
                return;
            }

            this.Close();
            Thread t = new Thread(() => Application.Run(new Trident()));
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
