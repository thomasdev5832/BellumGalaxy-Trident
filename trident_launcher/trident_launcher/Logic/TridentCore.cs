using System;
using System.Diagnostics;
using tridentApi;
using trident_interfaces;

namespace tridentCore
{
    internal class TridentCore
    {


        private Process findProcess(string processName, Process[] processes)
        {
            Process process = processes.FirstOrDefault(p => p.ProcessName.IndexOf(processName, StringComparison.OrdinalIgnoreCase) >= 0);
            return process;
        }


        public string manipulateProcess(Process[] processes)
        {
            string retorno = "";
            try
            {
                Console.WriteLine("inicio do processo");
                ApiConnection apiConnection = new ApiConnection();
                List<Games> listOfGamesForVerify = apiConnection.getGames();

                foreach (Games game in listOfGamesForVerify)
                {   
                    Process process = findProcess(game.Name, processes);

                    if (process != null)
                    {
                        Console.WriteLine($"Nome: {process.ProcessName}, ID: {process.Id}");
                        Console.WriteLine($"Processo encontrado para o jogo {game.Name}: {process.ProcessName}");
                        bool isClose = game.Isbloked;
                        if (isClose)
                        {
                        Console.WriteLine($"\nNome: {process.ProcessName}, Será encerrado");
                        bool isClosed = process.CloseMainWindow();
                        Console.WriteLine($"\nTempo do processo = {process.StartTime}");
                        Console.WriteLine($"\nProcesso encerrado: {isClosed}");
                        process.Kill();
                        break;
                        }

                    }
                }
                return $"Sucesso: {retorno}";
            }
            catch (Exception ex) {

                return $"deu erro: {ex}";
            
            }


          
        }

    }
}
