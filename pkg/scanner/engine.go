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

func LoadRules(ruleFilePath string) (*SecretRuleset, error) {
	data, err := os.ReadFile(ruleFilePath)
	if err != nil {
		return nil, err
	}
	var ruleset SecretRuleset
	err = yaml.Unmarshal(data, &ruleset)
	return &ruleset, err
}

func ScanDirectory(targetPath string, ruleset *SecretRuleset) {
	filepath.Walk(targetPath, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return nil
		}
func ParseRules(data []byte) (*SecretRuleset, error) {
	var ruleset SecretRuleset
	err := yaml.Unmarshal(data, &ruleset)
	return &ruleset, err
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
				}
			}
		}
		return nil
	})
}
