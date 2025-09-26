<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AndromedaHome</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"crossorigin="anonymous" />
  <style>
.blue-toolbar {
background-color: #0072CE;
color: white;
padding: 0.25rem 1rem;
min-height: 50px;
}
.navbar-brand {
color: white;
font-size: 1.1rem;
}
.navbar-brand img {
border-radius: 60px;
width: 40px;
height: 40px;
color: white;
}
.Search {
border-radius: 30px !important;
}
.blue-toolbar .nav-link,
.blue-toolbar .btn-link {
color: white;
}
.blue-toolbar .nav-link:hover,
.blue-toolbar .btn-link:hover {
color: #cce5ff;
text-decoration: none;
}
.blue-toolbar .nav-link i {
font-size: 1.3rem;
}
.panels-container {
display: flex;
gap: 20px;  
padding: 15px;
height: calc(105vh - 90px);
box-sizing: border-box;
}
.left-panel {
width: 200px;
min-width: 120px;
max-width: 600px;
background-color: #f8f9fa;
border: 1px solid #ddd;
border-radius: 8px;
overflow-y: auto;
overflow-x: hidden;       
padding: 1rem;
box-sizing: border-box;
resize: horizontal;
height: 100%;            
}
.right-panel {
flex-grow: 1;           
background-image: url('andromeda.png');
background-repeat: no-repeat;
background-position: center center;
background-size: contain;
border: 1px solid #ddd;
border-radius: 8px;
box-sizing: border-box;
height: 100%;            
}
.profile-dropdown {
position: absolute;
top: 60px;
right: 10px;
width: 200px;
background-color: white;
color: black;
border: 1px solid #ccc;
border-radius: 5px;
box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.3);
display: none;
z-index: 999;
}
.profile-dropdown p {
margin: 0;
padding: 10px;
font-size: 0.9rem;
border-bottom: 1px solid #eee;
}
.profile-dropdown button {
width: 100%;
padding: 8px 10px;
border: none;
background-color: #00AFC4;
color: white;
border-radius: 0 0 5px 5px;
cursor: pointer;
}
.profile-dropdown button:hover {
background-color: #008ba3;
}
.position-relative {
position: relative;
}
.modal {
display: none;
      position: fixed;
      z-index: 1050;
      left: 0;
      top: 0;
width: 100vw;
height: 100vh;
background-color: rgba(0, 0, 0, 0.3);
overflow: hidden; 
}
.modal-content {
background-color: white;
padding: 20px 25px 20px 25px; 
border-radius: 12px;
width: 700px;
max-height: 50vh; 
box-shadow: 0 8px 25px rgba(0, 0, 0, 0.35);
position: fixed;
top: 50%;
left: 60%;
transform: translate(-50%, -50%);
overflow-y: auto;
}
form label {
font-weight: 600;
}
form textarea,
form select,
form input {
margin-bottom: 15px;
padding: 8px 12px;
font-size: 1rem;
border-radius: 6px;
border: 1px solid #ccc;
transition: border-color 0.3s ease;
}
form textarea:focus,
form select:focus,
form input:focus {
border-color: #00afc4;
outline: none;
}
.close-button {
position: absolute;
right: 10px;
top: 5px;
font-size: 24px;
font-weight: bold;
cursor: pointer;
color: #333;
} 
.right-panel iframe {
width: 100%;
height: 100%;
border: none;
background-color: white; 
}
.loadingSpinner {
position: fixed;
top: 50%;
left: 50%;
transform: translate(-50%, -50%);
width: 50px;
height: 50px;
border: 5px solid #f3f3f3;
border-top: 5px solid #3498db;
border-radius: 50%;
animation: spin 1s linear infinite;
display: none; 
}
@keyframes spin {
0% { transform: rotate(0deg); }
100% { transform: rotate(360deg); }
}
   .blue-toolbar .nav-link i.fa-sign-out-alt {
  font-size: 1.3rem;
}
.search-wrapper {
  position: absolute;
  left: 50%;
  transform: translateX(-45%);
  top: 50%;
  transform: translateY(-40%) translateX(-70%);
  width: 25%; 
  max-width: 100%; 
}

#searchForm {
  display: flex;
  justify-content: center;
  align-items: center;
}
#searchForm input {
  width: 40%;  
  max-width: 100%;
}    
</style>
</head>
<body>
  <nav class="navbar navbar-expand-lg blue-toolbar position-relative">
    <div class="container-fluid">
      <div class="navbar-brand d-flex align-items-center">
        <img src="rr.png" alt="Logo" />
        <b class="ms-2">ANDROMEDA</b>
      </div> 
      <div class="search-wrapper">
  <form id="searchForm">
    <div class="input-group">
      <select id="searchFilter" class="form-select" style="max-width: 120px; border-top-left-radius: 30px; border-bottom-left-radius: 30px;">
        <option value="">All</option>
        <option value="byParts">byParts</option>
        <option value="byPersons">byPersons</option>
      </select>
       <input type="text" id="searchInput" class="form-control" placeholder="Search..." style="border-top-right-radius: 30px; border-bottom-right-radius: 30px;">
    </div>
    <button type="submit" id="searchButton" style="display: none;">Search</button>
  </form>
</div>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#headerComponents" aria-controls="headerComponents" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="headerComponents">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0 align-items-center">
        </ul>
        <ul class="navbar-nav mb-2 mb-lg-0 align-items-center">
          <li class="nav-item ms-3">
            <a class="nav-link" href="amxNavigatorHome.jsp"><i class="fas fa-house"></i></a>
          </li>
          <li class="nav-item ms-3 dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="plusDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
              <i class="fas fa-plus me-2"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="plusDropdown">
              <li><a class="dropdown-item" href="#" id="createPartLink">Create Part</a></li>
              <li><a class="dropdown-item" href="#" id="createPartControlLink">Create Part Control</a></li>
              <li><a class="dropdown-item" href="#" id="createPartSpecificationLink">Create Part Specification</a>
            </ul>
          </li>
          <li class="nav-item ms-3 position-relative">
            <a class="nav-link" href="#" onclick="toggleProfileDropdown(event)">
              <i class="fas fa-circle-user"></i>
            </a>
            <div class="profile-dropdown" id="profileDropdown">
              <p><strong>Username:</strong> <span id="usernameDisplay"></span></p>
              <p><strong>Email:</strong> <span id="emailDisplay"></span></p>
              <p><strong>Access:</strong> <span id="accessDisplay"></span></p>
            </div>
          </li>
          <li class="nav-item ms-3">
            <a class="nav-link" href="#" onclick="logout()" title="Logout">
              <i class="fa-regular fa-share-from-square"></i>
            </a>
          </li>
        </ul>
      </div>
    </div>
</nav>
  <div class="panels-container">
    <div class="left-panel">
      <ul class="nav flex-column">
  <li class="nav-item">
    <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorParts.jsp')">Parts</a>
  </li>
  <li class="nav item">
  <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPersons.jsp')">Persons</a>
  </li>
   <li class="nav item">
  <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPartControl.jsp')">PartControl</a>
  </li>
  <li class="nav-item">
  <a class="nav-link" href="#" onclick="loadRightPanel('amxRunSql.jsp')">RunSQL</a>
  </li>
</ul>
    </div>
   <iframe class="right-panel" id="contentFrame"  name="contentFrame" src="" frameborder="0"></iframe>
  </div>
  <div id="myModal" class="modal">
    <div class="modal-content">
      <span class="close-button"></span>
      <form id="createPartForm">
  <h2 class="mb-4">Create Part</h2>
  <div class="mb-3">
    <label for="supertype" class="form-label">SuperType</label>
    <select id="supertype" name="supertype" class="form-select" required>
      <option value="">Select</option>
    </select>
  </div>
  <div class="mb-3">
    <label for="type" class="form-label">Type</label>
    <select id="type" name="type" class="form-select" required>
      <option value="">Select</option>
    </select>
  </div>
  <div class="mb-3">
    <label for="APN" class="form-label">APN</label>
    <select id="APN" name="APN" class="form-select" required>
      <option value="">Select</option>
    </select>
  </div>
  <div class="mb-3">
    <label for="inputDescription" class="form-label">Description</label>
    <textarea id="inputDescription" class="form-control" rows="4" placeholder="Enter description"></textarea>
  </div>
  <div class="mb-3">
    <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
    <textarea id="inputResponsibleEngineer" class="form-control" rows="1" placeholder="username" readonly></textarea>
  </div>
  <div class="d-flex justify-content-end gap-2 mt-3">
    <button type="button" class="btn btn-secondary" id="cancelBtn">Cancel</button>
    <button type="submit" class="btn btn-primary">Submit</button>
  </div>
</form>
    </div>
  </div>
<div class="loadingSpinner" id="loadingSpinner"></div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  function loadPartPropertiesInIframe(objectId) {
	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'Properties.jsp?name=' + encodeURIComponent(objectId);
	}

    // Profile dropdown toggle and logout
    function toggleProfileDropdown(event) {
      event.preventDefault();
      const dropdown = document.getElementById('profileDropdown');
      dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(event) {
      const dropdown = document.getElementById('profileDropdown');
      const profileIcon = event.target.closest('.fa-circle-user');
      if (!profileIcon && !dropdown.contains(event.target)) {
        dropdown.style.display = 'none';
      }
    });
    function logout() {
      sessionStorage.removeItem('loggedInUser');
      window.location.href = 'amxNavigatorLogin.jsp';
    }
    function updateProfileDropdown() {
    	  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
    	  if (!user) {
    	    window.location.href = 'amxNavigatorLogin.jsp';
    	    return;
    	  }
    	  document.getElementById('usernameDisplay').textContent = user.username || '';
    	  document.getElementById('emailDisplay').textContent = user.email || '';
    	  document.getElementById('accessDisplay').textContent = user.access || '';

    	  fetch('http://localhost:8080/andromeda/api/navigatorutilites/login', {
    	    method: 'POST',
    	    headers: {
    	      'Content-Type': 'application/x-www-form-urlencoded'
    	    },
    	    credentials: 'include',
    	    body: new URLSearchParams({ username: user.username })
    	  })
    	  .then(res => res.json())
    	  .then(data => {
    	  })
    	  .catch(err => {
    	    console.error('Login error:', err);
    	    alert('Backend login failed. Please re-login.');
    	    window.location.href = 'amxNavigatorLogin.jsp';
    	  });
    	}
    window.addEventListener('DOMContentLoaded', async () => {
    	  updateProfileDropdown();

    	  const supertypeSelect = document.getElementById('supertype');
    	  const typeSelect = document.getElementById('type');
    	  const apnSelect = document.getElementById('APN');
    	  const descriptionInput = document.getElementById('inputDescription');
    	  const engineerInput = document.getElementById('inputResponsibleEngineer');
    	  const form = document.getElementById('createPartForm');
    	  const modal = document.getElementById('myModal');

    	  let dropdownData = {};

    	  try {
    	    const response = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
    	    dropdownData = await response.json();

    	    dropdownData.superTypes.forEach(supertype => {
    	      const option = new Option(supertype, supertype);
    	      supertypeSelect.add(option);
    	    });

    	    supertypeSelect.addEventListener('change', () => {
    	      const selectedSuper = supertypeSelect.value;
    	      typeSelect.innerHTML = '<option value="">Select</option>';
    	      apnSelect.innerHTML = '<option value="">Select</option>';
    	      descriptionInput.value = '';

    	      if (selectedSuper && dropdownData.types[selectedSuper]) {
    	        dropdownData.types[selectedSuper].forEach(type => {
    	          const option = new Option(type, type);
    	          typeSelect.add(option);
    	        });
    	      }
    	    });

    	    typeSelect.addEventListener('change', () => {
    	    	  const selectedType = typeSelect.value;
    	    	  apnSelect.innerHTML = '<option value="">Select</option>';
    	    	  descriptionInput.value = '';

    	    	  const normalizedKey = selectedType.replace(/\s+/g, '').toLowerCase();
    	    	  const apnList = dropdownData.apn && dropdownData.apn[normalizedKey];

    	    	  if (Array.isArray(apnList)) {
    	    	    apnList.forEach(apnWithLabel => {
    	    	      const label = apnWithLabel.trim();
    	    	      const option = new Option(label, label); 
    	    	      apnSelect.add(option);
    	    	    });
    	    	  }
    	    	});
    	    apnSelect.addEventListener('change', () => {
    	    });


    	  } catch (err) {
    	    console.error('Error loading dropdown data:', err);
    	    alert('Failed to load dropdown data.');
    	  }


    	  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
    	  if (user) {
    	    engineerInput.value = user.username || '';
    	  }

    	  const openModalBtn = document.getElementById('openModalBtn');
    	    if (openModalBtn) {
    	      openModalBtn.addEventListener('click', e => {
    	        e.preventDefault();
    	        modal.style.display = 'block';
    	      });
    	    }
    	    
    	  document.querySelector('.close-button').addEventListener('click', () => modal.style.display = 'none');
    	  document.getElementById('cancelBtn').addEventListener('click', () => modal.style.display = 'none');
    	  window.addEventListener('click', (event) => {
    	    if (event.target === modal) modal.style.display = 'none';
    	  });

    	  form.addEventListener('submit', async (e) => {
    	    e.preventDefault();
    	    const formData = {
    	      SuperType: supertypeSelect.value.trim(),
    	      Type: typeSelect.value.trim(),
    	      APN: apnSelect.value.trim(),
    	      Description: descriptionInput.value.trim(),

    	    };

    	    if (!formData.SuperType || !formData.Type || !formData.APN || !formData.Description) {
    	      alert('Please fill in all required fields.');
    	      return;
    	    }

    	    try {
    	      const res = await fetch('http://localhost:8080/andromeda/api/navigatorutilites/create', {
    	        method: 'POST',
    	        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    	        credentials: 'include',
    	        body: new URLSearchParams(formData)
    	      });
    	      const result = await res.json();

    	      if (!res.ok || result.Status !== 'Success') {
    	        alert('Error: ' + (result.Message || 'Something went wrong'));
    	        return;
    	      }

    	      alert('Part created successfully!');
    	      modal.style.display = 'none';
    	      form.reset();

    	    } catch (error) {
    	      alert('Submission failed: ' + error.message);
    	    }
    	  });
    	});

    
    function loadRightPanel(url) {
        const iframe = document.getElementById('contentFrame');
        iframe.src = url;
     
        if (url === 'amxDataFetch.jsp') {
          iframe.style.backgroundImage = 'none';
          iframe.style.backgroundColor = 'white';
        } else {
          iframe.style.backgroundImage = "url('andromeda.png')";
          iframe.style.backgroundColor = '';
        }
      }
    
    document.getElementById('createPartLink').addEventListener('click', function (e) {
    	  e.preventDefault();
    	  window.open('CreatePartForm.jsp', 'CreatePartPopup','width=600,height=700,resizable=yes,scrollbars=yes');
    	});  
    
    document.getElementById('createPartControlLink').addEventListener('click', function (e) {
  	  e.preventDefault();
  	  window.open('CreatePartControl.jsp', 'CreatePartPopup','width=600,height=700,resizable=yes,scrollbars=yes');
  	});  
  document.getElementById('createPartSpecificationLink').addEventListener('click',function(e){
	  e.preventDefault();
	  window.open('CreatePartSpecification.jsp','CreatePartSpecificatioPopup','width=600,height=700,resizable=yes,scrollable=yes');    
  });
 
 
    //search
  function showLoadingSpinner(show) {
  const spinner = document.getElementById('loadingSpinner');
  spinner.style.display = show ? 'block' : 'none';
}

  document.getElementById('searchForm').addEventListener('submit', function(event) {
	    event.preventDefault();

	    const searchInput = document.getElementById('searchInput');
	    const filterSelect = document.getElementById('searchFilter');
	    const searchQuery = searchInput.value.trim();
	    const filterValue = filterSelect.value.trim();

	    if (searchQuery.length < 2) {
	        alert('Please enter at least 2 characters');
	        return;
	    }
	    if (filterValue === null || filterValue === undefined) {
	    	  alert('Please select a filter');
	    	  return;
	    	}
	    showLoadingSpinner(true);

	    const loadingTimeout = setTimeout(() => {
	        showLoadingSpinner(false);
	    }, 10000);

	    const iframe = document.getElementById('contentFrame');
	    iframe.src = 'searchResults.jsp?query=' + encodeURIComponent(searchQuery) + '&filter=' + encodeURIComponent(filterValue);

	    searchInput.value = '';
	    iframe.style.backgroundImage = 'none';

	    iframe.onload = function() {
	        clearTimeout(loadingTimeout);
	        showLoadingSpinner(false);
	    };
	});
  </script>
</body>
</html>
