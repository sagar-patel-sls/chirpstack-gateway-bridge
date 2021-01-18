package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the ChirpStack Gateway Bridge version",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Version:", version)
		fmt.Println("Build Version:", buildVersion)
		fmt.Println("Build Date:", buildDate)
	},
}
