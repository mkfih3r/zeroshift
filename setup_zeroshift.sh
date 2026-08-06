#!/usr/bin/env bash

set -e

PROJECT_NAME="zeroshift"

echo "🚀 Initializing ZeroShift project structure..."

# 1. Create Directories
mkdir -p ${PROJECT_NAME}/cmd/rules
mkdir -p ${PROJECT_NAME}/pkg/scanner
mkdir -p ${PROJECT_NAME}/pkg/hunter
mkdir -p ${PROJECT_NAME}/rules

cd ${PROJECT_NAME}

# 2. Initialize Go Module
go mod init github.com/your-username/zeroshift
go get -u github.com/spf13/cobra@latest
go get gopkg.in/yaml.v3

# 3. Create main.go
cat << 'EOF' > main.go
package main

import (
	"fmt"
	"os"

	"github.com/your-username/zeroshift/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
EOF

# 4. Create Rules Files
cat << 'EOF' > rules/secrets.yaml
rules:
  - id: ZS-SEC-001
    name: "Hardcoded AWS Access Key"
    severity: "CRITICAL"
    pattern: "(?i)(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}"
    remediation: "Use environment variables or a secret manager instead of hardcoding AWS credentials."

  - id: ZS-SEC-002
    name: "Generic Private Key Exposure"
    severity: "HIGH"
    pattern: "-----BEGIN (RSA|OPENSSH|DSA|EC|PGP) PRIVATE KEY-----"
    remediation: "Remove private keys from the repository immediately and revoke them."

  - id: ZS-SEC-003
    name: "Hardcoded Generic API Key"
    severity: "MEDIUM"
    pattern: "(?i)(api[_-]?key|secret[_-]?key|token)\\s*[:=]\\s*['\"][a-zA-Z0-9_\\-]{16,}['\"]"
    remediation: "Move sensitive tokens to environment variable files (.env) and add .env to .gitignore."
EOF

cat << 'EOF' > rules/threats.yaml
rules:
  - id: ZS-TH-001
    name: "SQL Injection Payload Hit"
    severity: "HIGH"
    pattern: "(?i)(UNION\\s+SELECT|OR\\s+1=1|SELECT.*FROM|DROP\\s+TABLE)"
    remediation: "Enforce prepared statements / parameterized queries on web application inputs."

  - id: ZS-TH-002
    name: "SSH Brute Force Attempt"
    severity: "CRITICAL"
    pattern: "(?i)(Failed password for|Failed password for invalid user)"
    remediation: "Enable Fail2ban or restrict SSH access to trusted IP ranges only via firewall."

  - id: ZS-TH-003
    name: "Potential Directory Traversal"
    severity: "MEDIUM"
    pattern: "(\\.\\./\\.\\./|\\.\\.\\%2f\\.\\.\%2f)"
    remediation: "Sanitize user inputs and sanitize input file paths."
EOF

# Copy rules for embedding into cmd/rules
cp rules/*.yaml cmd/rules/

# 5. Create Engine Packages
cat << 'EOF' > pkg/scanner/engine.go
package scanner

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"

	"gopkg.in/yaml.v3"
)

type SecretRule struct {
	ID          string `yaml:"id"`
	Name        string `yaml:"name"`
	Severity    string `yaml:"severity"`
	Pattern     string `yaml:"pattern"`
	Remediation string `yaml:"remediation"`
}

type SecretRuleset struct {
	Rules []SecretRule `yaml:"rules"`
}

func ParseRules(data []byte) (*SecretRuleset, error) {
	var ruleset SecretRuleset
	err := yaml.Unmarshal(data, &ruleset)
	return &ruleset, err
}

func ScanDirectory(targetPath string, ruleset *SecretRuleset) bool {
	hasHigh := false
	filepath.Walk(targetPath, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return nil
		}

		file, err := os.Open(path)
		if err != nil {
			return nil
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		lineNumber := 0

		for scanner.Scan() {
			lineNumber++
			line := scanner.Text()

			for _, rule := range ruleset.Rules {
				matched, _ := regexp.MatchString(rule.Pattern, line)
				if matched {
					fmt.Printf("🚨 [%s] %s found in %s:%d\n", rule.Severity, rule.Name, path, lineNumber)
					fmt.Printf("   💡 Remediation: %s\n\n", rule.Remediation)
					if rule.Severity == "CRITICAL" || rule.Severity == "HIGH" {
						hasHigh = true
					}
				}
			}
		}
		return nil
	})
	return hasHigh
}
EOF

cat << 'EOF' > pkg/hunter/engine.go
package hunter

import (
	"bufio"
	"fmt"
	"os"
	"regexp"

	"gopkg.in/yaml.v3"
)

type ThreatRule struct {
	ID          string `yaml:"id"`
	Name        string `yaml:"name"`
	Severity    string `yaml:"severity"`
	Pattern     string `yaml:"pattern"`
	Remediation string `yaml:"remediation"`
}

type ThreatRuleset struct {
	Rules []ThreatRule `yaml:"rules"`
}

func ParseThreatRules(data []byte) (*ThreatRuleset, error) {
	var ruleset ThreatRuleset
	err := yaml.Unmarshal(data, &ruleset)
	return &ruleset, err
}

func HuntLogFile(logPath string, ruleset *ThreatRuleset) {
	file, err := os.Open(logPath)
	if err != nil {
		fmt.Printf("Error opening log file: %v\n", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNumber := 0

	for scanner.Scan() {
		lineNumber++
		line := scanner.Text()

		for _, rule := range ruleset.Rules {
			re := regexp.MustCompile(rule.Pattern)
			if re.MatchString(line) {
				fmt.Printf("🎯 [THREAT HUNTED] [%s] Line %d: %s\n", rule.Severity, lineNumber, rule.Name)
				fmt.Printf("   Raw Log: %s\n", line)
				fmt.Printf("   🛠️ Fix: %s\n\n", rule.Remediation)
			}
		}
	}
}
EOF

# 6. Create CLI Commands
cat << 'EOF' > cmd/embed.go
package cmd

import "embed"

//go:embed rules/*.yaml
var DefaultRulesFS embed.FS
EOF

cat << 'EOF' > cmd/root.go
package cmd

import (
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "zeroshift",
	Short: "ZeroShift — Lightweight, Proactive Security CLI Engine",
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
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "Enable verbose output")
}
EOF

cat << 'EOF' > cmd/shift.go
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
EOF

cat << 'EOF' > cmd/hunt.go
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

		hunter.HuntLogFile(logFilePath, ruleset)
	},
}

func init() {
	huntCmd.Flags().StringVarP(&logFilePath, "log", "l", "", "Path to log file to analyze")
	huntCmd.MarkFlagRequired("log")
	rootCmd.AddCommand(huntCmd)
}
EOF

cat << 'EOF' > cmd/guide.go
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
EOF

# 7. Final Clean Up and Build
go mod tidy
echo "🔨 Building ZeroShift executable..."
go build -o zeroshift main.go

echo "✅ ZeroShift setup complete!"
echo "Run './zeroshift --help' or './zeroshift guide' to test your executable."