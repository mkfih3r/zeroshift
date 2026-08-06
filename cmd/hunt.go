package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/your-username/zeroshift/pkg/hunter"
)

var (
	logFilePath string
)

var huntCmd = &cobra.Command{
	Use:   "hunt",
	Short: "Perform proactive threat hunting on logs and system state",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("🎯 [ZeroShift:Hunt] Analyzing Log Target: %s\n\n", logFilePath)

		// এম্বেড করা থ্রেট রুলস লোড করা
		ruleData, err := DefaultRulesFS.ReadFile("rules/threats.yaml")
		if err != nil {
			fmt.Printf("❌ Failed to load embedded threat rules: %v\n", err)
			os.Exit(1)
		}

		ruleset, err := hunter.ParseThreatRules(ruleData)
		if err != nil {
			fmt.Printf("❌ Failed to parse threat rules: %v\n", err)
			os.Exit(1)
		}

		// থ্রেট হান্টিং এঞ্জিন রান করা
		hunter.HuntLogFile(logFilePath, ruleset)
	},
}

func init() {
	huntCmd.Flags().StringVarP(&logFilePath, "log", "l", "", "Path to log file to analyze")
	huntCmd.MarkFlagRequired("log")
	rootCmd.AddCommand(huntCmd)
}
