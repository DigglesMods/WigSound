using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text;

namespace WigSound
{
    class Program
    {
        private static string soundFilePath = "Data/Sound/Sequenzen/";
        private static string errorFileName = "WigSoundErrors.txt";

        static void Main(string[] args)
        {
            //return at a wrong count of arguments
            if (args.Length != 3)
            {
                return;
            }

            try
            {
                //set decimal separator to "." (example: 1.213442)
                NumberFormatInfo numberFormat = new NumberFormatInfo();
                numberFormat.NumberDecimalSeparator = ".";

                //get arguments
                string clip = args[0];
                var start = float.Parse(args[1], numberFormat);
                var stop = float.Parse(args[2], numberFormat);
                var duration = stop - start;

                //add -mp3 if needed
                if (!clip.EndsWith(".mp3"))
                {
                    clip = clip + ".mp3";
                }

                //start madplay
                ProcessStartInfo startInfo = new ProcessStartInfo();
                startInfo.FileName = "madplay.exe";
                startInfo.Arguments = "-Q -s " + start.ToString(numberFormat) + " -t " + duration.ToString(numberFormat) + " " + soundFilePath + clip;
                startInfo.WindowStyle = ProcessWindowStyle.Hidden; // hide madplay window
                Process.Start(startInfo);
            }
            catch (Exception e)
            {
                //log exception
                StringBuilder builder = new StringBuilder();
                builder.Append("Arguments: ");
                builder.Append(string.Join(", ", args));
                builder.Append("\n");
                builder.Append(e.GetType());
                builder.Append(": ");
                builder.Append(e.Message);
                builder.Append("\n\n");
                File.AppendAllText(errorFileName, builder.ToString());
                builder.Clear();
            }
        }
    }
}
