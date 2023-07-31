package main

import (
	"context"
	"flag"
	"io/ioutil"
	"log"
	"os"

	"github.com/TobiasYin/go-lsp/logs"
	"github.com/TobiasYin/go-lsp/lsp"
	"github.com/TobiasYin/go-lsp/lsp/defines"
	"gopkg.in/yaml.v2"
)

type Configuration struct {
	Snippets map[string]string `yaml:",inline"`
}

func main() {
	configPath := flag.String("config", "config.yaml", "Path to the YAML config file")
	flag.Parse()

	data, err := ioutil.ReadFile(*configPath)
	if err != nil {
		log.Fatalf("Error reading config file: %v", err)
	}

	var config Configuration
	if err := yaml.Unmarshal(data, &config); err != nil {
		log.Fatalf("Error unmarshalling config data: %v", err)
	}

	logger := log.New(os.Stdout, "snippets-ls: ", log.LstdFlags)
	logs.Init(logger)

	server := lsp.NewServer(&lsp.Options{CompletionProvider: &defines.CompletionOptions{
		TriggerCharacters: &[]string{"."},
	}})

	items := make([]defines.CompletionItem, 0)
	k := defines.CompletionItemKindSnippet
	for snippetName, snippetBody := range config.Snippets {
		item := defines.CompletionItem{
			Kind:       &k,
			Label:      snippetName,
			InsertText: strPtr(snippetBody),
		}
		items = append(items, item)
	}

	server.OnCompletion(func(ctx context.Context, req *defines.CompletionParams) (result *[]defines.CompletionItem, err error) {
		logs.Println(req)
		return &items, nil
	})

	server.Run()
}

func strPtr(s string) *string {
	return &s
}
