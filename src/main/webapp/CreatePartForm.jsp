<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create Part</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
body {
  margin: 0;
  background-color: #f9f9f9;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: flex-start; 
}

#createPartForm {
  width: 100%;
  max-width: 600px; 
  padding: 30px;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 10px; 
  overflow-y: auto; 
}

h2 {
  margin-bottom: 15px; 
  color: #333;
  font-size: 22px; 
  font-weight: bold;
}

label {
  font-weight: 600;
  color: #555;
}

textarea,
select,
input {
  margin-bottom: 10px; 
  padding: 8px; 
  border-radius: 5px;
  border: 1px solid #ccc;
  font-size: 14px;
}

textarea:focus,
select:focus,
input:focus {
  border-color: #00afc4;
  box-shadow: 0 0 0 0.2rem rgba(0, 175, 196, 0.25);
}

.subtype-container,
#variant-container {
  display: none;
}

.subtype-container select,
#variant-container select {
  width: 100%;
}

.d-flex {
  display: flex;
  justify-content: flex-end;
}

.d-flex .btn {
  margin-left: 5px; 
  padding: 8px 16px;
  font-size: 14px; 
}

.mb-3 {
  margin-bottom: 10px; 
}

#subtype-container,
#variant-container {
  display: none;
}

#inputDescription,
#inputResponsibleEngineer {
  font-size: 14px;
}

#inputDescription {
  min-height: 80px; 
  font-family: Arial, sans-serif;
  font-size:14px;
}


#inputResponsibleEngineer {
  height: 30px;
}

button {
  padding: 8px 16px; 
  border-radius: 5px;
  font-size: 14px;
  cursor: pointer;
}

button[type="submit"] {
  background-color: #00afc4;
  color: white;
  border: none;
}

button[type="button"].btn-secondary {
  background-color: #6c757d;
  color: white;
}

button:hover {
  opacity: 0.9;
}

button[type="submit"]:hover {
  background-color: #007c8d;
}

button[type="button"].btn-secondary:hover {
  background-color: #5a6268;
}

textarea {
  font-size: 14px;
}

#inputDescription,
#inputResponsibleEngineer {
  height: auto;
  resize: vertical;
}

#inputDescription {
  min-height: 80px;
}

#inputResponsibleEngineer {
  height: 30px; 
}

@media screen and (max-width: 768px) {
  #createPartForm {
    padding: 20px;
    width: 100%;
  }
}

  </style>
</head>
<body>
  <form id="createPartForm">
    <h2>Create Part</h2>
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
    <!--new fields-->

    <div class="mb-3" id="subtype-container" style="display:none;">
      <label for="subtype" class="form-label">Subtype</label>
      <select id="subtype" name="subtype" class="form-select">
        <option value="">Select</option>
      </select>
    </div>
    <div class="mb-3" id="variant-container" style="display:none;">
      <label for="variant" class="form-label">Variant</label>
      <select id="variant" name="variant" class="form-select">
        <option value="">Select</option>
      </select>
    </div>

    <div class="mb-3">
      <label for="inputDescription" class="form-label">Description</label>
      <textarea id="inputDescription" class="form-control" rows="4" placeholder="Enter description" required></textarea>
    </div>
    <div class="mb-3">
      <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
      <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
    </div>
    <div class="d-flex justify-content-end gap-2">
       <button type="submit" class="btn btn-primary">Submit</button>
      <button type="button" class="btn btn-secondary" onclick="window.close()">Cancel</button>
    </div>
  </form>

  <script>
    window.addEventListener('DOMContentLoaded', async () => {
      const supertypeSelect = document.getElementById('supertype');
      const typeSelect = document.getElementById('type');
      const apnSelect = document.getElementById('APN');
       const subtypeContainer = document.getElementById('subtype-container');
      const variantContainer = document.getElementById('variant-container');
      const descriptionInput = document.getElementById('inputDescription');
      const engineerInput = document.getElementById('inputResponsibleEngineer');
      const form = document.getElementById('createPartForm');

      let dropdownData = {};

      // Load dropdown data
      try {
        const response = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
        dropdownData = await response.json();

        dropdownData.superTypes = dropdownData.superTypes || [];

        supertypeSelect.innerHTML = '<option value="">Select</option>';

        if (dropdownData.superTypes.includes('Part')) {
          const option = new Option('Part', 'Part');
          supertypeSelect.add(option);
        }


        supertypeSelect.addEventListener('change', () => {
          const selectedSuper = supertypeSelect.value;
          typeSelect.innerHTML = '<option value="">Select</option>';
          apnSelect.innerHTML = '<option value="">Select</option>';
          subtypeContainer.style.display = 'none';
          variantContainer.style.display = 'none';
          descriptionInput.value = '';

          if (selectedSuper && dropdownData.types[selectedSuper]) {
            dropdownData.types[selectedSuper].forEach(type => {
              const option = new Option(type, type);
              typeSelect.add(option);
            });
          }
        });

        	  typeSelect.addEventListener('change', () => {
        	  const selectedType = typeSelect.value.trim().toLowerCase();
        	  apnSelect.innerHTML = '<option value="">Select</option>';
        	  document.getElementById('subtype').innerHTML = '<option value="">Select</option>';
        	  document.getElementById('variant').innerHTML = '<option value="">Select</option>';
        	  document.getElementById('subtype-container').style.display = 'none';
        	  document.getElementById('variant-container').style.display = 'none';
        	  descriptionInput.value = '';

        	  // Populate APN dropdown
        	  const normalizedKey = selectedType.replace(/\s+/g, '').toLowerCase();
        	  const apnList = dropdownData.apn && dropdownData.apn[normalizedKey];

        	  if (Array.isArray(apnList)) {
        	    apnList.forEach(apnWithLabel => {
        	      const option = new Option(apnWithLabel, apnWithLabel);
        	      apnSelect.add(option);
        	    });
        	  }

        	  if (selectedType === 'fastener') {
        		    document.getElementById('subtype-container').style.display = 'block';
        		    document.getElementById('variant-container').style.display = 'block';
        		}
        	});

			 apnSelect.addEventListener('change', () => {
        	  const selectedType = typeSelect.value.trim().toLowerCase();
        	  const selectedAPN = apnSelect.value;

        	  if (selectedType === 'fastener' && selectedAPN) {
        	    const rawLabel = selectedAPN.split('-')[1]?.trim() || '';
        	    const apnKeyMap = {"Bolts": "bolts","Nuts": "nuts","Screws": "screws","Rivets": "rivets","Washers": "washers","Clips & Clamps": "clips & clamps",
        	    		"Pins": "pins","Fastener for Interior": "interior","Electrical System Fastener": "electrical","Security Fastener": "security",
        	    		"Fasteners for Body Panels": "body-panels","Suspension & Steering": "suspension & steering","Engine&Mechanical": "engine & mechanical",
  						"Exhaust System": "exhaust","Fuel System": "fuel-system","Brake System": "brake-system","Transmission": "transmission",
  						"Radiator & Cooling": "radiator & cooling","Underbody & Frame": "underbody & frame","Miscellaneous Fastener": "miscellaneous"};
        	    const apnKey = apnKeyMap[rawLabel];

        	    const subtypeSelect = document.getElementById('subtype');
        	    const variantSelect = document.getElementById('variant');
        	    subtypeSelect.innerHTML = '<option value="">Select</option>';
        	    variantSelect.innerHTML = '<option value="">Select</option>';

        	    if (apnKey) {
        	    
        	      const subtypesRaw = dropdownData.fastenerSubtypes[apnKey];
        	      if (subtypesRaw && subtypesRaw.length > 0) {
        	        subtypesRaw[0].split(',').map(s => s.trim()).forEach(subtype => {
        	          subtypeSelect.add(new Option(subtype, subtype));
        	        });
        	      } else {
        	      }

        	      const variantsRaw = dropdownData.fastenerVariants[apnKey];
        	      if (variantsRaw && variantsRaw.length > 0) {
        	        variantsRaw[0].split(',').map(v => v.trim()).forEach(variant => {
        	          variantSelect.add(new Option(variant, variant));
        	        });
        	      } else {
        	      }

        	      document.getElementById('subtype-container').style.display = 'block';
        	      document.getElementById('variant-container').style.display = 'block';
        	    } else {
        	      document.getElementById('subtype-container').style.display = 'none';
        	      document.getElementById('variant-container').style.display = 'none';
        	    }
        	  } else {
        	    document.getElementById('subtype-container').style.display = 'none';
        	    document.getElementById('variant-container').style.display = 'none';
        	  }
        	});


      } catch (err) {
        alert('Failed to load dropdown data.');
      }

      const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
      if (user) {
        engineerInput.value = user.username || '';
      } else {
        alert('No logged-in user. Please log in.');
        window.close();
      }

   // Form submission
      form.addEventListener('submit', async (e) => {
    	    e.preventDefault();

    	    // Create form data object
    	    const formData = {
    	        SuperType: supertypeSelect.value.trim(),
    	        Type: typeSelect.value.trim(),
    	        APN: apnSelect.value.trim(),
    	        Subtype: document.getElementById('subtype').value.trim(), // This is your subtype value
    	        Variant: document.getElementById('variant').value.trim(),
    	        Description: descriptionInput.value.trim(),
    	        ResponsibleEngineer: engineerInput.value.trim()
    	    };

    	    if (formData.Type.toLowerCase() === 'fastener') {
    	        formData.FastenerSubPart = formData.Subtype;  
    	        delete formData.Subtype;  
    	    }

    	    // Validation
    	    if (!formData.SuperType || !formData.Type || !formData.APN || !formData.Description) {
    	        alert('Please fill in all required fields.');
    	        return;
    	    }

    	    if (formData.Type.toLowerCase() === 'fastener') {
    	        if (!formData.FastenerSubPart || !formData.Variant) {
    	            alert('FastenerSubPart and Variant are required when Type is Fastener.');
    	            return;
    	        }
    	    }

    	    // Submit data
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
    	        const successMessage = "The following object was created successfully!\n"
    	            + "SuperType: " + formData.SuperType + "\n"
    	            + "Type: " + formData.Type + "\n"
    	            + "Name: " + formData.APN;
    	        alert(successMessage);

    	        const objectId = result.ObjectId; 
    	        if (objectId) {
    	            if (window.opener && window.opener.loadPartPropertiesInIframe) {
    	                window.opener.loadPartPropertiesInIframe(objectId); 
    	            }
    	            window.close();
    	        } else {
    	            alert('Could not retrieve the ID for the new part.');
    	        }
    	    } catch (error) {
    	        alert('Submission failed: ' + error.message);
    	    }
    	});

    });
  </script>
</body>
</html>