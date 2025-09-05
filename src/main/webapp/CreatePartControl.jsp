<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create Part Control</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body {
      margin: 0;
      background-color: #f9f9f9;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    #createPartForm {
      width: 100%;
      max-width: 600px;
      padding: 30px;
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }
    h2 {
      margin-bottom: 20px;
    }
    label {
      font-weight: 600;
    }
    textarea,
    select,
    input {
      margin-bottom: 15px;
    }
    .form-control:focus,
    .form-select:focus {
      border-color: #00afc4;
      box-shadow: 0 0 0 0.2rem rgba(0, 175, 196, 0.25);
    }
  </style>
</head>
<body>
  <form id="createPartForm">
    <h2>Create Part Control</h2>

    <div class="mb-3">
      <label for="supertype" class="form-label">SuperType</label>
      <select id="supertype" name="SuperType" class="form-select" required>
        <option value="">Select</option>
      </select>
    </div>

    <div class="mb-3">
      <label for="type" class="form-label">Type</label>
      <select id="type" name="Type" class="form-select" required>
        <option value="">Select</option>
      </select>
    </div>

    <div class="mb-3">
      <label for="inputDescription" class="form-label">Description</label>
      <textarea id="inputDescription" name="Description" class="form-control" rows="4" placeholder="Enter description" required></textarea>
    </div>

    <div class="mb-3">
      <label for="inputAssignee" class="form-label">Assignee</label>
      <input type="text" id="inputAssignee" name="Assignee" class="form-control" placeholder="Enter assignee" required />
    </div>

    <div class="d-flex justify-content-end gap-2">
      <button type="button" class="btn btn-secondary" id="cancelBtn">Cancel</button>
      <button type="submit" class="btn btn-primary">Submit</button>
    </div>
  </form>

<script>
  const isInIframe = window.self !== window.top;
  document.getElementById('cancelBtn').addEventListener('click', () => {
    if (isInIframe) {
      window.parent.postMessage({ action: 'closeOnly' }, '*');
    } else {
      window.close();
    }
  });

  document.addEventListener('DOMContentLoaded', async () => {
    const supertypeSelect = document.getElementById('supertype');
    const typeSelect = document.getElementById('type');
    const assigneeInput = document.getElementById('inputAssignee');
    const descriptionInput = document.getElementById('inputDescription');
    const form = document.getElementById('createPartForm');

    let dropdownData = {};

    try {
    	  const res = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
    	  if (!res.ok) throw new Error('Failed to load dropdown data');
    	  dropdownData = await res.json();

    	  if ((dropdownData.superTypes || []).includes('AmxControl')) {
    	    const option = new Option('AmxControl', 'AmxControl');
    	    supertypeSelect.add(option);
    	  }
      const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
      if (user && user.username) {
        assigneeInput.value = user.username;
      } else {
        alert('No logged-in user. Please log in.');
        if (isInIframe) {
          window.parent.postMessage({ action: 'closeOnly' }, '*');
        } else {
          window.close();
        }
        return;
      }
    } catch (error) {
      alert(error.message || 'Failed to load dropdown data.');
      return;
    }

    supertypeSelect.addEventListener('change', () => {
      const selectedSuper = supertypeSelect.value;
      typeSelect.innerHTML = '<option value="">Select</option>';
      if (selectedSuper && dropdownData.types && dropdownData.types[selectedSuper]) {
        dropdownData.types[selectedSuper].forEach(type => {
          const option = new Option(type, type);
          typeSelect.add(option);
        });
      }
    });

    form.addEventListener('submit', async (e) => {
      e.preventDefault();

      const formData = {
        SuperType: supertypeSelect.value.trim(),
        Type: typeSelect.value.trim(),
        Assignee: assigneeInput.value.trim(),
        Description: descriptionInput.value.trim()
      };

      if (!formData.SuperType || !formData.Type || !formData.Assignee || !formData.Description) {
        alert('Please fill in all required fields.');
        return;
      }

      try {
        const res = await fetch('http://localhost:8080/andromeda/api/datafetchservice/createpartcontrol', {  
          method: 'POST',
          headers: { 
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          credentials: 'include',
          body: new URLSearchParams(formData)
        });

        const result = await res.json();

        if (!res.ok || result.Status !== 'Success') {
          alert('Error: ' + (result.Message || 'Something went wrong'));
          return;
        }

        alert('The following object was created successfully!\nSuperType: ' + formData.SuperType + '\nType: ' + formData.Type +
        		  '\nName: ' + result.Name);
        if (isInIframe) {
          window.parent.postMessage({ action: 'closeAndRefresh' }, '*');
        } else {
  
          window.close();
        }

      } catch (error) {
        alert('Submission failed: ' + error.message);
      }
    });
  });
</script>
</body>
</html>