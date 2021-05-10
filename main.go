package main

import (
	"fmt"
	"log"
	"os"

	"github.com/jmmaloney4/conductor/game"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:  "conductor",
	Long: "A Ticket-To-Ride Simulator.",
	Args: cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(args[0])

		mapfile, err := os.Open(args[0])
		if err != nil {
			log.Fatal(err)
		}

		game.ImportJSONMap(mapfile)
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Get the version of this app.",
	Long:  "Get the version of this app.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("0.0.0 -- Use at your own risk!")
	},
}

func main() {
	rootCmd.AddCommand(versionCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
