package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var guideCmd = &cobra.Command{
	Use:   "guide",
	Short: "Interactive security mentor and hardening guide",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("🧠 [ZeroShift:Mentor] Interactive Remediation & Security Best Practices")
		fmt.Println("---------------------------------------------------------------------")
		fmt.Println("1. Ensure secret scanners run on git pre-commit hooks.")
		fmt.Println("2. Enforce Least Privilege Access across all servers.")
		fmt.Println("3. Monitor /var/log/auth.log for failed SSH brute-force attempts.")
	},
}

func init() {
	rootCmd.AddCommand(guideCmd)
}
