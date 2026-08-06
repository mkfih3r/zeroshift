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

func LoadThreatRules(ruleFilePath string) (*ThreatRuleset, error) {
	data, err := os.ReadFile(ruleFilePath)
	if err != nil {
		return nil, err
	}
	var ruleset ThreatRuleset
	err = yaml.Unmarshal(data, &ruleset)
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
