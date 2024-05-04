using System.Diagnostics;
using tridentCore;

namespace trident_launcher
{
    public partial class Trident : Form
    {
        private bool _logged;
        public Trident()
        {
            InitializeComponent();
            ConfigureForm();

        }
        private bool verifyLogin(string username, string password)
        {
            const string UsuarioCorreto = "";
            const string SenhaCorreta = "";
            if (UsuarioCorreto == username && SenhaCorreta == password)
            {
                return true;
            }
            return false;
        }

        private void MenuPage()
        {
            initTrident.Visible = true;
            menuGroup.Visible = true;
            loginBox.Visible = false;

        }

        private void loginPage()
        {
            initTrident.Visible = false;
            menuGroup.Visible = false;
        }
        private void ConfigureForm()
        {

            if (_logged)
            {
                MenuPage();
            }
            else
            {
                loginPage();
            }
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
            _logged = true;
            ConfigureForm();

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
    }
}
