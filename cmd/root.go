package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "zeroshift",
	Short: "ZeroShift — Lightweight, Proactive Security CLI",
	Long: `ZeroShift is a proactive security tool built upon three core pillars:
  1. Shift Left (DevSecOps Code & Dependency Audit)
  2. Proactive Threat Hunting (Log Anomaly & Drift Detector)
  3. Security Mentor (Interactive Guidance & Remediation)`,
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	// Global Flags can be added here
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "Enable verbose output")
}
