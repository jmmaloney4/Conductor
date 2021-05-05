package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:  "conductor",
	Long: "A Ticket-To-Ride Simulator.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Hello, World!")
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
