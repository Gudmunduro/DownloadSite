
let token = "";
let loggedIn = false;

var Manager = {
    setUIState (state) {
        switch (state) {
            case 0:
            {
                // Title
                let title = document.getElementById("title");
                title.innerText = "Login";
                title.className = "title LoginTitle";
                // Login form
                let loginForm = document.getElementById("loginForm");
                loginForm.className = "loginForm";
                // Manager form
                let managerForm = document.getElementById("managerForm");
                managerForm.className = "managerForm disabled";
                break;
            }
            case 1:
            {
                // Title
                let title = document.getElementById("title");
                title.innerText = "Manager";
                title.className = "title";
                // Login form
                let loginForm = document.getElementById("loginForm");
                loginForm.className = "loginForm disabled";
                // Manager form
                let managerForm = document.getElementById("managerForm");
                managerForm.className = "managerForm";
                break;
            }
        }
    },
    fileList: {
        files: [
            {
                id: 0,
                name: "File1.exe",
                size: "50mb",
                tag: "file1"
            },
            {
                id: 1,
                name: "File2.exe",
                size: "51mb",
                tag: "file2"
            }
        ],
        async setup()
        {
            try {
                this.files = (await axios.get("/api/files")).data;
            } catch (error) {
                console.log(error);
                alert("Failed to load files");
            }
            renderFileList();
        },
        renderFileList() {
            let fileList = document.getElementById("fileList");
            fileList.innerHTML = "";

            for (let file of this.files) {
                let mainE = document.createElement("span");
                mainE.className = "fileListElement";
                // Info
                let infoE = document.createElement("span");
                let nameAndSizeE = document.createElement("span");
                let filenameE = document.createElement("h1");
                let sizeE = document.createElement("p");

                infoE.className = "info";
                nameAndSizeE.className = "nameAndSize";
                filenameE.innerText = file.name;
                sizeE.innerText = "?mb";// file.size;

                infoE.appendChild(nameAndSizeE);
                nameAndSizeE.appendChild(filenameE);
                nameAndSizeE.appendChild(sizeE);
                mainE.appendChild(infoE);
                // Actions
                let actionsE = document.createElement("span");
                let tagInputE = document.createElement("input");
                let activateButtonE = document.createElement("a");
                let deleteButtonE = document.createElement("a");

                actionsE.className = "actions";
                tagInputE.className = "baseTextInput";
                tagInputE.type = "text";
                activateButtonE.className = "baseButton activateButton";
                activateButtonE.innerText = "Activate";
                deleteButtonE.className = "baseButton deleteButton";
                deleteButtonE.innerText = "Delete";

                actionsE.appendChild(tagInputE);
                actionsE.appendChild(activateButtonE);
                actionsE.appendChild(deleteButtonE);
                mainE.appendChild(actionsE);

                fileList.appendChild(mainE);
            }
        }
    },
    loginForm: {
        set loginButtonEnabled(enabled)
        {
            switch (enabled) {
                case true:
                {
                    let loginButton = document.getElementById("loginButton");
                    loginButton.disabled = false;
                    loginButton.className = "baseButton loginButton";
                    break;
                }
                case false:
                {
                    let loginButton = document.getElementById("loginButton");
                    loginButton.disabled = true;
                    loginButton.className = "baseButton loginButton baseButtonDisabled";
                    break;
                }
            }
        },
        async login() {
            const username = document.getElementById("usernameField").value;
            const password = document.getElementById("passwordField").value;
            this.loginButtonEnabled = false;
            let response;
            try {
                response = await axios.post('/api/login', {}, {
                    auth: {
                        username,
                        password
                    }
                });
            } catch {
                alert("Login failed")
                this.loginButtonEnabled = true;
            }

            token = response.data.token;
            loggedIn = true;
            Manager.setUIState(1);
            Manager.fileList.setup();
        }
    }
};
