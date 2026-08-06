package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/your-username/zeroshift/pkg/scanner"
)

var (
	scanPath   string
	failOnHigh bool
)

var shiftCmd = &cobra.Command{
	Use:   "shift",
	Short: "Scan codebases and configurations for secrets and vulnerabilities (Shift Left)",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("🔍 [ZeroShift:Shift] Initializing DevSecOps Scanner on: %s\n\n", scanPath)

		// এম্বেড করা ডিফোল্ট রুলস লোড করা
		ruleData, err := DefaultRulesFS.ReadFile("rules/secrets.yaml")
		if err != nil {
			fmt.Printf("❌ Failed to load embedded secret rules: %v\n", err)
			os.Exit(1)
		}

		ruleset, err := scanner.ParseRules(ruleData)
		if err != nil {
			fmt.Printf("❌ Failed to parse rules: %v\n", err)
			os.Exit(1)
		}

		// স্ক্যানার রান করা
		hasHighSeverity := scanner.ScanDirectory(scanPath, ruleset)

		if hasHighSeverity && failOnHigh {
			fmt.Println("⚠️ High/Critical vulnerabilities found. Failing pipeline due to --fail-on-high flag.")
			os.Exit(1)
		}
	},
}

func init() {
	shiftCmd.Flags().StringVarP(&scanPath, "path", "p", ".", "Path to scan")
	shiftCmd.Flags().BoolVar(&failOnHigh, "fail-on-high", false, "Exit with code 1 if critical/high issues exist")
	rootCmd.AddCommand(shiftCmd)
}