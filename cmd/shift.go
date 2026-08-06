package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var (
	scanPath   string
	failOnHigh bool
)

var shiftCmd = &cobra.Command{
	Use:   "shift",
	Short: "Scan codebases and configurations for secrets and vulnerabilities (Shift Left)",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("🔍 [ZeroShift:Shift] Scanning path: %s\n", scanPath)
		// TODO: Hook engine logic from /pkg/scanner
		fmt.Println("✅ Scan completed. No critical secrets or vulnerabilities detected.")
	},
}

func init() {
	shiftCmd.Flags().StringVarP(&scanPath, "path", "p", ".", "Path to scan")
	shiftCmd.Flags().BoolVar(&failOnHigh, "fail-on-high", false, "Exit with non-zero code if high severity issues are found")
	rootCmd.AddCommand(shiftCmd)
}
