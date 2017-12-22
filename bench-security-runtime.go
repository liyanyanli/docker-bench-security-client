package main

import (
	"time"
	"os"
	"encoding/json"
	"fmt"
	"bufio"
	"strings"
	"os/exec"
	"net"
	"bytes"
	"net/http"
	"strconv"
)

const cmdRuntime  = "sh /usr/local/deploy-harbor/docker-bench-security-harmony/runtime.sh"
const harborUrlRun = "/api/benchSecurityRuntime"



type Configuration struct {
	HarborIp        string
	Freq            int
	FreqRuntime     int
}

type RuntimeOut struct {
	ContainerID   string `json:"container_id"`
	ContainerName string `json:"container_name"`
	Runtime       string `json:"runtime"`
}

type RuntimeOutList struct {
	Ip          string `json:"ip"`
	RunTimeList []RuntimeOut `json:"runTime_list"`
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

func post(parameter string, ip string, u string) error {
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
	return err
}

func getContainers(time int) (map[string]string) {
	containers := make(map[string]string)
	result := execCommand("find /var/lib/docker/containers/ -maxdepth 1 -mmin -" + strconv.Itoa(time) + " | awk -F '/' '{print $NF}'")
	if result == "" {
		return nil
	}

	scanner := bufio.NewScanner(strings.NewReader(result))
	if err := scanner.Err(); err != nil {
		fmt.Println("error:", err)
		//os.Exit(1)
	}

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		} else {

			containerName := execCommand("docker ps -a --no-trunc | grep " + line + " |awk '{print $NF}'")
			containers[line] = containerName
		}
	}
	return containers
}

func main() {
	conf := getConfiguration()
	retryTime := 0
		for {
			time.Sleep(time.Duration(conf.FreqRuntime*40) * time.Second)
			var runtimeOut RuntimeOut
			var runTimeList RuntimeOutList
			containers := make(map[string]string)
			containers = getContainers(conf.FreqRuntime + retryTime)

			retryTime = 0
			if len(containers) == 0 {
				continue
			}

			for key, value := range containers {
				runtime := execCommand(cmdRuntime + " " + value)
				runtimeOut.Runtime = runtime
				runtimeOut.ContainerID = key
				runtimeOut.ContainerName = value

				runTimeList.RunTimeList = append(runTimeList.RunTimeList,runtimeOut)

			}

			runTimeList.Ip = getIp()

			out, err := json.Marshal(runTimeList)
			if err != nil {
				fmt.Println(err)
				//os.Exit(1)
			}
			outS := string(out)
			err1 := post(outS, conf.HarborIp,harborUrlRun)

			if err1 != nil {
				for {
					time.Sleep(time.Duration(30) * time.Minute)
					retryTime = retryTime + 30
					err2 := post(outS, conf.HarborIp,harborUrlRun)
					if err2 == nil {
						break
					}
				}
			}
		}
}




