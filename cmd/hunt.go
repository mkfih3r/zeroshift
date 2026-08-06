package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var (
	logFilePath string
	ruleSet     string
)

var huntCmd = &cobra.Command{
	Use:   "hunt",
	Short: "Perform proactive threat hunting on logs and system state",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("🎯 [ZeroShift:Hunt] Analyzing log file: %s using ruleset: %s\n", logFilePath, ruleSet)
		// TODO: Hook engine logic from /pkg/hunter
		fmt.Println("🛡️ Threat hunting active. Searching for anomalies...")
	},
}

func init() {
	huntCmd.Flags().StringVarP(&logFilePath, "log", "l", "", "Path to log file to analyze")
	huntCmd.Flags().StringVarP(&ruleSet, "ruleset", "r", "default", "Ruleset to use for threat hunting")
	huntCmd.MarkFlagRequired("log")
	rootCmd.AddCommand(huntCmd)
}
