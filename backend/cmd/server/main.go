package main

import (
	"fmt"
	"os"
	"../../pkg/db"
)

func main() {
	pbURL := os.Getenv("POCKETBASE_URL")
	
	if pbURL == "" {
		pbURL = "http://localhost:8090"
	}

	pbClient := db.NewPocketBaseClient(pbURL)
	adminEmail := os.Getenv("POCKETBASE_ADMIN_EMAIL")
	adminPass := os.Getenv("POCKETBASE_ADMIN_PASSWORD")
	
	if adminEmail != "" && adminPass != "" {
		err := pbClient.AuthAdmin(adminEmail, adminPass)
		if err != nil {
			fmt.Printf("Error autenticando con PocketBase: %v\n", err)
		} else {
			fmt.Println("Conexión exitosa a PocketBase como Admin")
		}
	}

	fmt.Println("Servidor iniciado...")
}