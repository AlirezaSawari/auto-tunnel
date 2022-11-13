# traffic balancer and auto tunneler
A sample script to create fake upload traffic and tunnel automatically

## Installation

You need two servers, the first server is the one where you want to increase upload traffic. And the second server is the server that is supposed to download from the first server.
In this tutorial, we call the first server domestic server and the second server foreign server

### Install in domestic server
- run this command in terminal:
    ```bash
      curl -o install.sh -L https://raw.githubusercontent.com/AlirezaSawari/auto-tunnel/main/install.sh && bash install.sh
    ```

- This is domestic server or foreign server?

  - type 1 and enter


- Do you want to tunnel?
  - if you want tunnel to foreign server type yes and enter and in next question type foreign server IP but if you don't want to tunnel and just want to create fake upload traffic type no and enter
    
  
  After completing the installation, you will be given a link that you must copy so that you can use it on the foreign server

### Install in foreign server
- run this command in terminal:
    ```bash
      curl -o install.sh -L https://raw.githubusercontent.com/AlirezaSawari/auto-tunnel/main/install.sh && bash install.sh
    ```
- This is domestic server or foreign server?

  - type 2 and enter


- enter Link to Download it:
  - In this step, you must enter the link you received from the domestic server
