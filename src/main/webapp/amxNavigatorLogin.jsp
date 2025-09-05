<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Andromeda - Login & Register</title>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: 'Times New Roman', serif;
      display: flex;
      height: 100vh;
      background-color: #ffffff;
      overflow: hidden;
    }

    .left, .right {
      flex: 1;
      height: 100vh;
    }

    .left {
      flex: 0.7; 
      background: url('andro.png') no-repeat center;
      background-size: contain;
      background-color: #ffffff;
      border-right: 2px solid #e0e0e0;
    }

    .right {
      flex: 1.3; 
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding: 20px;
      max-width: 480px;
      margin: auto;
    }

    .form-container {
      width: 100%;
      animation: fadeIn 0.3s ease-in-out;
    }
    h1 {
      font-size: 1.5rem;
      font-weight: bold;
      margin-bottom: 25px;
      color: #2c3e50;
      text-align: center;
      font-style: italic;
    }

    form {
      width: 90%;
    }

    label {
      display: block;
      margin-bottom: 6px;
      font-weight: bold;
      font-style: italic;
      color: #2c3e50;
    }
	  .form-container:nth-of-type(2) {
      padding: 10px 20px;
      max-height: 600px;
      overflow-y: auto;
    }
    
    input[type="text"],
    input[type="password"],
    input[type="email"],
    select {
      width: 80%;
      padding: 10px;
      border: 2px solid #ccc;
      border-radius: 6px;
      margin-bottom: 18px;
      font-size: 1rem;
      transition: border-color 0.3s ease;
    }

  
#registerForm input[type="text"],
#registerForm input[type="password"],
#registerForm input[type="email"],
#registerForm select {
  padding: 5px 8px;
  font-size: 0.85rem;
  margin-bottom: 10px;
}

#registerForm label {
  margin-bottom: 4px;
  font-size: 0.85rem;
}


    input[type="text"]:focus,
    input[type="password"]:focus,
    input[type="email"]:focus,
    select:focus {
      border-color: #2980b9;
      outline: none;
    }

    input[type="submit"] {
      width: 80%;
      padding: 12px;
      background-color: #2980b9;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 1rem;
      cursor: pointer;
      font-weight: bold;
      transition: background-color 0.3s ease;
    }

    input[type="submit"]:hover:not(:disabled) {
      background-color: #1c6690;
    }

    input[type="submit"]:disabled {
      background-color: #7f9bbd;
      cursor: not-allowed;
    }

    .toggle-link {
      font-size: 0.9rem;
      margin-top: 10px;
    }

    .toggle-link a {
      color: #2980b9;
      font-weight: bold;
      text-decoration: none;
      cursor: pointer;
    }

    .toggle-link a:hover {
      text-decoration: underline;
    }

    .message-box {
      width: 100%;
      padding: 15px;
      margin-bottom: 20px;
      border-radius: 6px;
      font-size: 1rem;
      text-align: center;
      font-style: italic;
      font-weight: bold;
      display: none;
    }

    .message-success {
      background-color: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
    }

    .message-error {
      background-color: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
    }

    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    @media (max-width: 768px) {
      body {
        flex-direction: column;
      }
      .left, .right {
        flex: none;
        width: 100%;
        height: auto;
      }
      .left {
        height: 200px;
        background-size: cover;
        background-position: center;
      }
    }
  </style>
</head>
<body>
  <div class="left"></div>
  <div class="right">
    <div id="messageBox" class="message-box"></div>
    <!-- Login Form -->
    <div class="form-container">
      <h1>Welcome to Andromeda Application</h1>
      <form id="loginForm">
        <label for="loginUsername">Username:</label>
        <input type="text" id="loginUsername" name="username" required autocomplete="username" />
        <label for="loginPassword">Password:</label>
        <input type="password" id="loginPassword" name="password" required autocomplete="current-password" />
        <input type="submit" value="Login" />
      </form>
      <div class="toggle-link">
        Don't have an account?
        <a href="#" onclick="toggleForm('register'); return false;">Create an account</a>
      </div>
    </div>
    <!-- Register Form -->
    <div class="form-container" style="display:none;">
      <h1>Create Your Account</h1>
      <form id="registerForm">
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required />
        <label for="regUsername">Username:</label>
        <input type="text" id="regUsername" name="username" required />
        <label for="firstname">First Name:</label>
        <input type="text" id="firstname" name="firstname" required />
        <label for="lastname">Last Name:</label>
        <input type="text" id="lastname" name="lastname" required />
        <label for="regPassword">Password:</label>
        <input type="password" id="regPassword" name="password" required />
        <label for="confirmPassword">Confirm Password:</label>
        <input type="password" id="confirmPassword" name="confirmPassword" required />
        <label for="country">Country:</label>
        <select id="country" name="country" required>
          <option value="">Select Country</option>
          <option value="Australia">Australia</option>
          <option value="Canada">Canada</option>
          <option value="Germany">Germany</option>
          <option value="India">India</option>
          <option value="United States">United States</option>
        </select>
        <label for="access">Access:</label>
      <input type="text" value="Reader" readonly />
      <input type="hidden" name="Access" value="Reader" />
        <input type="submit" value="Register" />
      </form>
      <div class="toggle-link">
        Already have an account?
        <a href="#" onclick="toggleForm('login'); return false;">Login here</a>
      </div>
    </div>
  </div>

  <script>
    $(document).ready(() => {
      function toggleForm(formType) {
        if (formType === 'login') {
          $('#registerForm').closest('.form-container').hide();
          $('#loginForm').closest('.form-container').fadeIn();
        } else {
          $('#loginForm').closest('.form-container').hide();
          $('#registerForm').closest('.form-container').fadeIn();
        }
      }

      function disableForm(formSelector, disabled) {
        $(`${formSelector} :input`).prop('disabled', disabled);
      }

      function showMessage(message, type = 'success', duration = 3000) {
        const box = $('#messageBox');
        box.removeClass('message-success message-error');
        box.addClass(type === 'success' ? 'message-success' : 'message-error');
        box.text(message).fadeIn();
        setTimeout(() => {
          box.fadeOut();
        }, duration);
      }

      $('#loginForm').on('submit', function (e) {
        e.preventDefault();
        const username = $('#loginUsername').val().trim();
        const password = $('#loginPassword').val().trim();
        if (!username || !password) {
          showMessage('Please enter both username and password.', 'error');
          return;
        }
        disableForm('#loginForm', true);
        $.ajax({
          url: 'http://localhost:8080/andromeda/api/myresource/login',
          type: 'POST',
          contentType: 'application/x-www-form-urlencoded',
          data: $.param({
            Username: username,
            Password: password
          }),
          success: (response) => {
            const res = typeof response === 'string' ? JSON.parse(response) : response;
            if (res.Status === "Success") {
              showMessage('Login successful!', 'success');
              sessionStorage.setItem('loggedInUser', JSON.stringify({
            	  username: res.Username,
            	  email: res.Email,
            	  firstname: res.Firstname,
            	  lastname: res.Lastname,
            	  access: res.Access 
            	}));
              setTimeout(() => {
                window.location.href = 'amxNavigatorHome.jsp';
              }, 1000);
            } else {
              showMessage('Login failed: ' + res.Message, 'error');
            }
          },
          error: (xhr) => {
            try {
              const err = JSON.parse(xhr.responseText);
              showMessage('Login error: ' + err.Message, 'error');
            } catch {
              showMessage('Login error: Server error.', 'error');
            }
          },
          complete: () => {
            disableForm('#loginForm', false);
          }
        });
      });

      $('#registerForm').on('submit', function (e) {
        e.preventDefault();
        const email = $('#email').val().trim();
        const username = $('#regUsername').val().trim();
        const firstname = $('#firstname').val().trim();
        const lastname = $('#lastname').val().trim();
        const password = $('#regPassword').val().trim();
        const confirmPassword = $('#confirmPassword').val().trim();
        const country = $('#country').val();
        const access = $('#registerForm input[name="Access"]').val();

        if (!email || !username || !firstname || !lastname || !password || !confirmPassword || !country) {
          showMessage('All fields are required.', 'error');
          return;
        }

        if (password !== confirmPassword) {
          showMessage('Passwords do not match.', 'error');
          return;
        }

        disableForm('#registerForm', true);

        $.ajax({
          url: 'http://localhost:8080/andromeda/api/myresource/register',
          type: 'POST',
          contentType: 'application/x-www-form-urlencoded',
          data: $.param({
            Email: email,
            Username: username,
            Firstname: firstname,
            Lastname: lastname,
            Password: password,
            ConfirmPassword: confirmPassword,
            Country: country,
            Access:access
          }),
          success: (response) => {
            const res = typeof response === 'string' ? JSON.parse(response) : response;
            if (res.Status === "Success") {
              showMessage('Registration successful!', 'success');
              $('#registerForm')[0].reset();
              setTimeout(() => {
                toggleForm('login');
              }, 2000);
            } else {
              showMessage('Registration failed: ' + res.Message, 'error');
            }
          },
          error: (xhr) => {
            try {
              const err = JSON.parse(xhr.responseText);
              showMessage('Registration error: ' + err.Message, 'error');
            } catch {
              showMessage('Registration error: Server error.', 'error');
            }
          },
          complete: () => {
            disableForm('#registerForm', false);
          }
        });
      });

      window.toggleForm = toggleForm;
    });
  </script>
</body>
</html>
