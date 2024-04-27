# ECommerce Tea Store Rest Api
 
# What is this?

This is a repository for running the backend API used in [Build Real World ECommerce App with .NET MAUI](https://www.udemy.com/course/build-real-world-ecommerce-app-with-net-maui/) on Docker.

In the video, the built `ECommerceApi.csproj` is running on Azure, but I wanted to run it in WSL2 + Docker environment, so I added containers etc.

# Assumption

- Docker and Docker Compose must be running
- Windows11

# Usage Procedure

Move to an appropriate working folder. In this case, we place it on the desktop.

```powershell
# This is Windows

> cd $env:USERPROFILE\Desktop

> git clone git@github.com:shimanamisan/ECommerce-Tea-Store-Rest-Api.git
```

Start wsl2 in a terminal.

```bash
# This is wsl2

$ mkdir docker_work

$ cp -r /mnt/c/Users/[Your Desktop]ECommerce-Tea-Store-Rest-Api/SQLServer ~/docker_work

$ cd docker_work/SQLServer

$ docker compose up -d

$ docker exec -it [container id] bash

$ ls -la
# Verify that the script is present
#-rwxr-xr-x   1 root root 2831 Apr 27 05:04 postCreateCommand.sh

$ ./postCreateCommand.sh 'Hn_Pgtech1234' './bin/Debug/' './'
# A database named ECommerceApiDb009 is created.
```

Preparation to perform migration.

Confirm that the `ApiDbContextConnection` in `appsettings.json` looks like this.

```json
{
  // omission

  "ConnectionStrings": {
    "ApiDbContextConnection": "Server=127.0.0.1,1433;Database=ECommerceApiDb009;User Id=sa;Password=Hn_Pgtech1234;Connect Timeout=5;TrustServerCertificate=true;"
  },

}
```

Install and run the migration tool.

```powershell
# This is Windows

> dotnet tool install --global dotnet-ef --version 7.0.13

> cd ECommerce-Tea-Store-Rest-Api\ECommerceApi\ECommerceApi

> dotnet ef database update
```

If necessary, use a tool such as DBeaver to verify that it has been created successfully.

![スクリーンショット 2024-04-27 145426](https://github.com/shimanamisan/ECommerce-Tea-Store-Rest-Api/assets/49751604/ffa31d4f-50c4-429c-a40f-be30edb4e650)

Open `ECommerceApi.sln` in Visual Studio 2022 and start the project.

![image](https://github.com/shimanamisan/ECommerce-Tea-Store-Rest-Api/assets/49751604/4d48a78d-2ab0-46e2-85b0-00fc0c03961a)

Ensure that you can view the swagger administration page at `https://localhost:7205/swagger/index.html`.

![image](https://github.com/shimanamisan/ECommerce-Tea-Store-Rest-Api/assets/49751604/d7ce07a3-d1a3-430b-abea-a151b11e80b5)

We can then import the Postman configuration distributed in the course and test the API.

Change the baseURL to your current environment.

![image](https://github.com/shimanamisan/ECommerce-Tea-Store-Rest-Api/assets/49751604/75312ad1-f9ec-47f4-93d6-6d21897e7868)