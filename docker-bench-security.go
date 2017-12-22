package main

import (
	"time"
	"os"
	"encoding/json"
	"os/exec"
	"net"
	"bytes"
	"net/http"
	"fmt"
)

const cmdHost  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/host.sh"
const cmdDaemon  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/daemon.sh"
const cmdDaemonFile  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/daemon-file.sh"
const cmdImages  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/images.sh"
//const cmdRuntime  = "sh runtime.sh"
const cmdOperation  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/operations.sh"

const harborUrl  =  "/api/benchSecurity"

type Configuration struct {
	HarborIp        string
	Freq            int
	FreqRuntime     int
}

type Output struct {
	Ip         string `json:"ip"`
	Host       string `json:"host"`
	Daemon     string `json:"daemon"`
	DaemonFile string `json:"daemonFile"`
	Images     string `json:"images"`
	//Runtime    string `json:"runtime"`
	Operation  string `json:"operation"`
}

func getConfiguration() Configuration {
	file, _ := os.Open("bench-security-conf.json")
	decoder := json.NewDecoder(file)
	configuration := Configuration{}
	err := decoder.Decode(&configuration)
	if err != nil {
		fmt.Println("error:", err)
		//os.Exit(1)
	}

	return configuration
}

func execCommand(param string) (string){
	f, err := exec.Command("/bin/sh", "-c", param).Output()
	if err != nil {
		fmt.Println("error:", err)
		//os.Exit(1)
	}
	return string(f)
}

func getIp() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		fmt.Println("error:", err)
		//os.Exit(1)
	}

	var ip string

	for _, address := range addrs {
		if ipnet, ok := address.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				ip = ipnet.IP.String()
				break
			}
		}
	}

	return ip
}

func post(parameter string, ip string, u string) {
	url := "http://" + ip + u
	var jsonStr = []byte(parameter)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonStr))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("error:", err)
		////os.Exit(1)
	} else {
		defer resp.Body.Close()
	}
}

func main() {
	conf := getConfiguration()
	var output Output
	for {
		go func() {
			host := execCommand(cmdHost)
			output.Host = host

			daemon := execCommand(cmdDaemon)
			output.Daemon = daemon

			daemonFile := execCommand(cmdDaemonFile)
			output.DaemonFile = daemonFile

			image := execCommand(cmdImages)
			output.Images = image

			//runtime := execCommand(cmdRuntime)
			//output.Runtime = runtime

			operations := execCommand(cmdOperation)
			output.Operation = operations


			output.Ip = getIp()
			out, err := json.Marshal(output)
			if err != nil {
				fmt.Println(err)
				//os.Exit(1)
			}
			outS := string(out)
			post(outS,conf.HarborIp,harborUrl)
		}()
		time.Sleep(time.Duration(conf.Freq) * time.Hour)
	}
}





