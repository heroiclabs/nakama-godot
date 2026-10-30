// Copyright 2022 The Nakama Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using Godot;

namespace Nakama
{
    /// <summary>
    /// A logger that prints to the Godot console.
    /// </summary>
    public class GodotLogger : ILogger
    {
        /// <summary>
        /// The log level.
        /// </summary>
        public enum LogLevel
        {
            NONE,
            ERROR,
            WARNING,
            INFO,
            DEBUG,
        }

        private string module;
        private LogLevel level;

        /// <summary>
        /// Constructs a GodotLogger.
        /// </summary>
        /// <param name="module">The label to use for log entries.</param>
        /// <param name="level">The most verbose log level to print to the console.</param>
        public GodotLogger(string module = "Nakama", LogLevel level = LogLevel.ERROR)
        {
            this.module = module;
            this.level = level;
        }

        /// <inheritdoc cref="ILogger.ErrorFormat"/>
        public void ErrorFormat(string format, params object[] args)
        {
            if (level >= LogLevel.ERROR)
            {
                GD.PrintErr("=== " + module + " : ERROR === " + string.Format(format, args));
            }
        }

        /// <inheritdoc cref="ILogger.WarnFormat"/>
        public void WarnFormat(string format, params object[] args)
        {
            if (level >= LogLevel.WARNING)
            {
                GD.Print("=== " + module + " : WARNING === " + string.Format(format, args));
            }
        }

        /// <inheritdoc cref="ILogger.InfoFormat"/>
        public void InfoFormat(string format, params object[] args)
        {
            if (level >= LogLevel.INFO)
            {
                GD.Print("=== " + module + " : INFO === " + string.Format(format, args));
            }
        }

        /// <inheritdoc cref="ILogger.DebugFormat"/>
        public void DebugFormat(string format, params object[] args)
        {
            if (level >= LogLevel.DEBUG)
            {
                GD.Print("=== " + module + " : DEBUG === " + string.Format(format, args));
            }
        }
    }
}
