package cmd

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var guideCmd = &cobra.Command{
	Use:   "guide",
	Short: "Interactive security mentor for remediation and capacity building",
	Long:  `ZeroShift Guide acts as your hands-on security companion, walking you through step-by-step hardening and remediation strategies based on the three core pillars.`,
	Run: func(cmd *cobra.Command, args []string) {
		runInteractiveMentor()
	},
}

func init() {
	rootCmd.AddCommand(guideCmd)
}

func runInteractiveMentor() {
	reader := bufio.NewReader(os.Stdin)

	fmt.Println("🧠 ========================================================")
	fmt.Println("         ZEROSHIFT INTERACTIVE SECURITY MENTOR             ")
	fmt.Println("============================================================")
	fmt.Println("Select a domain to harden your environment:")
	fmt.Println("  [1] DevSecOps & Pipeline Hardening (Shift Left)")
	fmt.Println("  [2] Proactive Threat Hunting Setup (Zero Trust Monitoring)")
	fmt.Println("  [3] Human Error Reduction Checklist")
	fmt.Println("  [4] Exit")
	fmt.Print("\nChoose an option [1-4]: ")

	input, _ := reader.ReadString('\n')
	input = strings.TrimSpace(input)

	switch input {
	case "1":
		showDevSecOpsGuide(reader)
	case "2":
		showThreatHuntingGuide(reader)
	case "3":
		showHumanErrorChecklist(reader)
	case "4":
		fmt.Println("Keep your systems resilient! Goodbye.")
	default:
		fmt.Println("❌ Invalid choice. Exiting mentor.")
	}
}

func showDevSecOpsGuide(reader *bufio.Reader) {
	fmt.Println("\n🛡️  [Pillar 1: Shift Left Strategy]")
	fmt.Println("------------------------------------------------------------")
	fmt.Println("Step 1: Install ZeroShift in your local Git pre-commit hook.")
	fmt.Println("        Command: echo 'zeroshift shift --fail-on-high' > .git/hooks/pre-commit")
	fmt.Println("        Command: chmod +x .git/hooks/pre-commit")
	fmt.Println("\nStep 2: Ensure .env files and API keys are added to .gitignore.")
	fmt.Println("Step 3: Enforce automated dependency scanning on every PR.")
	
	askForVerification(reader, "Have you enabled pre-commit hooks on this repository?")
}

func showThreatHuntingGuide(reader *bufio.Reader) {
	fmt.Println("\n🎯 [Pillar 2: Proactive Threat Hunting Setup]")
	fmt.Println("------------------------------------------------------------")
	fmt.Println("Step 1: Enable central logging for Nginx/Apache auth logs.")
	fmt.Println("Step 2: Run periodic log scanning using ZeroShift:")
	fmt.Println("        Command: zeroshift hunt --log /var/log/auth.log")
	fmt.Println("Step 3: Monitor for anomalous file integrity modifications.")

	askForVerification(reader, "Is log forwarding configured to prevent attackers from wiping local logs?")
}

func showHumanErrorChecklist(reader *bufio.Reader) {
	fmt.Println("\n👨‍💻 [Pillar 3: Human Capacity & Error Reduction]")
	fmt.Println("------------------------------------------------------------")
	fmt.Println("Checklist for system operators:")
	fmt.Println(" [✓] Disable password authentication for SSH (Use Ed25519 Keys only)")
	fmt.Println(" [✓] Restrict administrative interfaces behind VPNs/Zero-Trust Access")
	fmt.Println(" [✓] Implement Least Privilege Access (No root/admin usage for routine tasks)")
	fmt.Println("\nRemember: Security tools only protect against errors if the operator follows safe practices.")
}

func askForVerification(reader *bufio.Reader, question string) {
	fmt.Printf("\n❓ Verification Check: %s (y/n): ", question)
	answer, _ := reader.ReadString('\n')
	answer = strings.TrimSpace(strings.ToLower(answer))

	if answer == "y" || answer == "yes" {
		fmt.Println("✅ Great job! Your proactive stance significantly lowers risk.")
	} else {
		fmt.Println("⚠️ Action Recommended: Address this gap to strengthen your defense posture.")
	}
}
