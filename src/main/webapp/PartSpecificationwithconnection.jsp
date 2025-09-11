<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Part Specification with connection</title>
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
    <h2>Create Part Specification</h2>

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
      <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
      <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
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
	  const engineerInput = document.getElementById('inputResponsibleEngineer'); 
	  const descriptionInput = document.getElementById('inputDescription');
	  const form = document.getElementById('createPartForm');

	  let dropdownData = {};

	  try {
	    const res = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
	    if (!res.ok) throw new Error('Failed to load dropdown data');
	    dropdownData = await res.json();

	    if ((dropdownData.superTypes || []).includes('Document')) {
	      const option = new Option('Document', 'Document');
	      supertypeSelect.add(option);
	    }

	    const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
	    if (user && user.username) {
	      engineerInput.value = user.username;  
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

		    const urlParams = new URLSearchParams(window.location.search);
		    const objectid = urlParams.get('name');
		    if (!objectid) {
		        alert('Object ID is missing');
		        return;
		    }

		    const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
		    const partspecification = {
		            supertype: supertypeSelect.value.trim(),
		            type: typeSelect.value.trim(),
		            description: descriptionInput.value.trim(),
		            owner: user?.username || '',
		            email: user?.email || '',
		            objectid: objectid
		        };
		    const payload = {
		        partSpecification: partspecification
		    };

		    try {
		        const res = await fetch('http://localhost:8080/andromeda/api/datafetchservice/partspecificationwithconnection', {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		                'Accept': 'application/json'
		            },
		            credentials: 'include',
		            body: JSON.stringify(payload)
		        });

		        const result = await res.json();
		        if (!res.ok || result.error) {
		            if (result.error && result.error.includes("already exists")) {
		                alert(`Error: ${result.error}`);
		            } else {
		                alert('Error: ' + (result.error || 'Failed to create part specification'));
		            }
		            return;
		        }

		        alert('The following object was created successfully!\n' +
		              'SuperType: ' + partspecification.SuperType + '\n' +
		              'Type: ' + partspecification.Type + '\n' +
		              'Name: ' + result.name);

		        onPartSpecificationCreationSuccess();
		    } catch (error) {
		        alert('Submission failed: ' + error.message);
		    }

		    function onPartSpecificationCreationSuccess() {
		        window.parent.postMessage({ action: 'closeAndRefresh' }, '*');
		    }
		});

  });
</script>
</body>
</html>