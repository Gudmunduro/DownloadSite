
let loggedIn = false;

let Manager = {
    setUIState (state) {
        switch (state) {
            case 0:
            {
                // Title
                let title = document.getElementById('title');
                title.innerText = 'Login';
                title.className = 'title LoginTitle';
                // Login form
                let loginForm = document.getElementById('loginForm');
                loginForm.className = 'loginForm';
                this.loginForm.loginButtonEnabled = true;
                // Manager form
                let managerForm = document.getElementById('managerForm');
                managerForm.className = 'managerForm disabled';
                break;
            }
            case 1:
            {
                // Title
                let title = document.getElementById('title');
                title.innerText = 'Manager';
                title.className = 'title';
                // Login form
                let loginForm = document.getElementById('loginForm');
                loginForm.className = 'loginForm disabled';
                // Manager form
                let managerForm = document.getElementById('managerForm');
                managerForm.className = 'managerForm';
                break;
            }
        }
    },
    fileList: {
        files: [],

        async setup() {
            try {
                this.files = (await axios.get('/api/files')).data;
            } catch (error) {
                console.log(error);
                alert('Failed to load files');
            }
            this.renderFileList();
        },

        renderFileList() {
            let fileList = document.getElementById('fileList');
            fileList.innerHTML = '';

            fileList.ondrop = this.onFileDrop;
            fileList.ondragover = (e) => { e.preventDefault(); e.stopPropagation(); }
            fileList.ondragleave = (e) => { e.preventDefault(); e.stopPropagation(); }

            for (let file of this.files) {
                let mainE = document.createElement('span');
                mainE.className = 'fileListElement';
                // Info
                let infoE = document.createElement('span');
                let nameAndSizeE = document.createElement('span');
                let filenameE = document.createElement('h1');
                let sizeE = document.createElement('p');

                infoE.className = 'info';
                nameAndSizeE.className = 'nameAndSize';
                filenameE.innerText = file.filename;
                sizeE.innerText = '?mb';// file.size;

                infoE.appendChild(nameAndSizeE);
                nameAndSizeE.appendChild(filenameE);
                nameAndSizeE.appendChild(sizeE);
                mainE.appendChild(infoE);
                // Actions
                let actionsE = document.createElement('span');
                let tagInputE = document.createElement('input');
                let activateButtonE = document.createElement('a');
                let deleteButtonE = document.createElement('a');

                actionsE.className = 'actions';
                tagInputE.className = 'baseTextInput';
                tagInputE.type = 'text';
                tagInputE.value = file.fileTag;
                activateButtonE.className = 'baseButton activateButton';
                activateButtonE.innerText = 'Activate';
                deleteButtonE.className = 'baseButton deleteButton';
                deleteButtonE.innerText = 'Delete';

                actionsE.appendChild(tagInputE);
                actionsE.appendChild(activateButtonE);
                actionsE.appendChild(deleteButtonE);
                mainE.appendChild(actionsE);

                fileList.appendChild(mainE);
            }
        },

        onFileUploadButtonPressed()
        {
            document.getElementById('fileInput').click();
        },

        async onFileDrop(e) {
            e.preventDefault();
            e.stopPropagation();

            const file = e.target.files[0];
            const fileTag = prompt('Enter file tag');

            await this.uploadFile(file, fileTag);

            this.setup();
        },

        async onFileDialogChanged(e)
        {
            const file = e.target.files[0];
            const fileTag = prompt('Enter file tag');
            
            await this.uploadFile(file, fileTag);

            this.setup();
        },

        async uploadFile(file, fileTag) {
            let formData = new FormData();
            formData.append('file', file);
            formData.append('fileTag', fileTag)

            let response;
            try {
                response = await axios.post('/api/upload', formData, {
                    headers: {
                        'Content-Type': 'multipart/form-data'
                    }
                })
            } catch (error) {
                alert('Failed to upload file');
                console.log(error);
            }
        },

        async logout() {
            loggedIn = false;

            if (!localStorage.getItem('token')) {
                console.log('Token not found in localStorage');
                console.log('Logout failed, ')
                Manager.setUIState(0);
                localStorage.removeItem('token');
                return;
            }

            try {
                await axios.post('/api/logout');
            } catch (error) {
                console.log('Logout failed');
                console.log(error);
                Manager.setUIState(0);
                localStorage.removeItem('token');
            }

            Manager.setUIState(0);
            localStorage.removeItem('token');
        }
    },
    loginForm: {
        set loginButtonEnabled(enabled) {
            switch (enabled) {
                case true:
                {
                    let loginButton = document.getElementById('loginButton');
                    loginButton.disabled = false;
                    loginButton.className = 'baseButton loginButton';
                    break;
                }
                case false:
                {
                    let loginButton = document.getElementById('loginButton');
                    loginButton.disabled = true;
                    loginButton.className = 'baseButton loginButton baseButtonDisabled';
                    break;
                }
            }
        },

        async login() {
            const username = document.getElementById('usernameField').value;
            const password = document.getElementById('passwordField').value;

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
                alert('Login failed')
                this.loginButtonEnabled = true;
            }

            const token = response.data.token;

            localStorage.setItem('token', token);
            axios.defaults.headers.common['Authorization'] = 'Bearer ' + token;
            loggedIn = true;
            Manager.setUIState(1);
            Manager.fileList.setup();
        }
    }
};

function onload () {
    if (localStorage.getItem('token')) {
        const token = localStorage.token;
        axios.defaults.headers.common['Authorization'] = 'Bearer ' + token;
        loggedIn = true;
        Manager.setUIState(1);
        Manager.fileList.setup();
    }
}

window.addEventListener('load', onload);