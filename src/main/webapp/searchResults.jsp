<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" rel="stylesheet" />

<style>

.spinner-container {
  position: relative;
  width: 80px;
  height: 80px;
  margin: 40px auto 10px auto;
}

.spinner-ring {
  box-sizing: border-box;
  position: absolute;
  width: 80px;
  height: 80px;
  border: 6px solid #f3f3f3;
  border-top: 6px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  top: 0;
  left: 0;
}
  .spinner-overlay {
  position: fixed;      
  top: 0; left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(255, 255, 255, 0.7); 
  display: flex;
  flex-direction: column;   
  justify-content: center;  
  align-items: center;      
  gap: 10px;
  z-index: 9999;
}

.spinner-image {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loadingText {
  font-weight: bold;
  font-size: 1.1rem;
  color: #3498db;
}

a.apn-link {
cursor: pointer;
color: blue;
text-decoration: underline;
}
.noResults {
  display: none;
  position: fixed; 
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%); 
  text-align: center;
  font-size: 18px;
  color: #555;
  background-color: transparent;
  border: none;
  box-shadow: none;
  padding: 0;
  margin: 0;
  width: auto;
  max-width: 90%;
  z-index: 10000; 
}
.noResults ul {
list-style: none;
padding: 0;
 }
.noResults li {
font-size: 16px;
color: #555;
}
.table-wrapper {
text-wrap-mode : nowrap;
position: relative;
min-height: 200px;
}
.resultsTable thead th {
background-color: #f8f9fa;
}
.inline-bullets {
  padding: 0;
  margin: 0;
  list-style-type: none; 
}

.inline-bullets li {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
  font-size: 16px; 
}

.inline-bullets li::before {
  content: '•';  
  font-size: 20px;  
  margin-right: 3px;  
}

.tight-columns td, .tight-columns th {
    padding: 2px 4px !important; /* reduce padding */
}
#resultsTable {
    border-collapse: collapse !important;
    table-layout: auto;
}

#resultsTable thead th {
    padding: 2px 8px !important;
    font-size: 12px !important;
    line-height: 1 !important;
    vertical-align: middle !important;
    height: 28px !important;
}

</style>
</head>
<body class="container mt-4">
    <!-- Loading Spinner -->
<div id="spinnerOverlay" class="spinner-overlay" style="display: flex; flex-direction: column; gap: 10px; align-items: center;">
  <div class="spinner-container" style="position: relative; width: 80px; height: 80px;">
    <div class="spinner-ring"></div>
    <img src="logo.png" alt="loading image" class="spinner-image" /></div>
  <div id="loadingText" class="loadingText" style="font-weight: bold;">Loading...</div></div>
  
    <div id="errorMessage" class="alert alert-danger" style="display:none;"></div>
    <div id="contextMenu" style="display:none; position:absolute; background:#fff; border:1px solid #ccc; box-shadow:0 2px 6px rgba(0,0,0,0.2); z-index:1000;">
        <ul style="list-style:none; margin:0; padding:5px 0; width:100px;">
            <li id="openMenuItem" style="padding:8px 15px; cursor:pointer;">Open</li>
        </ul>
    </div>

    <div id="noResults" class="noResults">
    <h2 style="font-weight: bold; font-size:32px;">No Result Found</h2>
    <h4>Suggestions:</h4>
    <ul class="inline-bullets">
        <li>Make sure all words are spelled correctly</li>
        <li>Try different keywords.</li>
        <li>Try more general keywords.</li>
    </ul>
</div>
    <div class="table-wrapper">
        <table id="resultsTable" class="display table table-striped" style="width:100%; display:none;">
            <thead>
                <tr id="tableHeaderRow">
                    
                </tr>
            </thead>
            <tbody id="resultsBody">
                
            </tbody>
        </table>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script>
    document.addEventListener('DOMContentLoaded', async function () {
        const urlParams = new URLSearchParams(window.location.search);
        const query = urlParams.get('query');
        const filter = urlParams.get('filter') || 'all';

        const errorMessage = document.getElementById('errorMessage');
        const resultsTable = $('#resultsTable');
        const resultsBody = document.getElementById('resultsBody');
        const tableHeaderRow = document.getElementById('tableHeaderRow');
        const contextMenu = document.getElementById('contextMenu');
        const noResultsDiv = document.getElementById('noResults'); 
        let selectedObjectId = null;
        function showLoading(show) {
            const spinnerOverlay = document.getElementById('spinnerOverlay');
            const loadingText = document.getElementById('loadingText');
            if (show) {
                spinnerOverlay.style.display = 'flex';
                loadingText.style.display = 'block';
            } else {
                spinnerOverlay.style.display = 'none';
                loadingText.style.display = 'none';
            }
        }
        function showError(msg) {
            errorMessage.textContent = msg;
            errorMessage.style.display = 'block';
            showLoading(false);
            resultsTable.hide();
        }
        function isValidPartNumber(query) {
            const regex = /^[0-9]{3}(-\d{3})?(-APN)?$/;
            return regex.test(query);
        }
        function isOnlyNumbers(query) {
            return /^\d+$/.test(query);
        }

        if (!query) {
            showError("Please enter a search value.");
            return;
        }

        const searchQuery = query.trim().toLowerCase();

        if (filter === "all") {
            const isNumericLike = /^[0-9]+(-[0-9]*)?$/.test(searchQuery);
            const isAlphaLike = /^[a-z]+(-[a-z0-9]*)?$/.test(searchQuery);
            
            if (!isNumericLike && !isAlphaLike) {
                showError("Invalid input format. Use values like '900', '900-001', 'pc', or 'pc-000'.");
                return;
            }
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters.");
                return;
            }
        } else if (filter === "byparts") {
            if (isOnlyNumbers(searchQuery)) {
                showError("Please enter a valid part name, not just a number.");
                return;
            }
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters for part name.");
                return;
            }
        } else {
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters.");
                return;
            }
        }
        try {
            showLoading(true);
            errorMessage.style.display = 'none';
            resultsTable.hide();
            noResultsDiv.style.display = 'none';  
            const formData = new URLSearchParams();
            formData.append("name", query);
            formData.append("filter", filter);
            const response = await fetch("http://localhost:8080/andromeda/api/navigatorutilites/amxfullsearch?" + formData.toString(), {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (!response.ok) {
                if (response.status === 404) {
                    renderNoResults();
                    showLoading(false);
                    return;
                } else {
                    const errText = await response.text();
                    throw new Error(errText);
                }
            }
            const data = await response.json();
            if (data.Status === "Success" && Array.isArray(data.Results) && data.Results.length > 0) {
                renderResults(data.Results);
            } else {
                renderNoResults();
            }
        } catch (error) {
            console.error("Error fetching results:", error);
            showError("There was an issue fetching results.");
        } finally {
            showLoading(false);
        }
        function renderResults(results) {
            resultsTable.show();
            noResultsDiv.style.display = 'none';
            errorMessage.style.display = 'none';
            resultsBody.innerHTML = '';
            tableHeaderRow.innerHTML = '';

            let headerMap;
            if (searchQuery === 'pc' || searchQuery === 'pc-' || searchQuery === 'pc-000') {
                headerMap = {"Name": "name","SuperType": "supertype","Type": "type","Description": "description",
                    "Createddate": "createddate","Owner": "owner","Email": "email","Assignee": "assignee","Currentstate": "currentstate"
                };
            } else if (filter === "byPersons") {
                headerMap = {"Username": "username","First Name": "firstname","Last Name": "lastname","Country": "country",
                    "Email": "email","Access": "access"
                };
            } else if (filter === "byParts") {
                headerMap = {"APN": "apn","Name": "name","SuperType": "supertype","Type": "type","Description": "description"
                };
            } else {
                headerMap = {"APN": "apn","Name": "name","SuperType": "supertype","Type": "type","Description": "description",
                    "CreatedDate": "createddate","Owner": "owner","Email": "email"
                };
            }
            Object.keys(headerMap).forEach(header => {
                const th = document.createElement('th');
                th.textContent = header;
                tableHeaderRow.appendChild(th);
            });

            results.forEach((item, index) => {
                const tr = document.createElement('tr');
                const rowClass = index % 2 === 0 ? 'even' : 'odd';
                tr.classList.add(rowClass);

                if (item.objectid) {
                    const safeObjectIdClass = 'id-' + item.objectid.replace(/[^a-zA-Z0-9\-_]/g, '-');
                    tr.classList.add(safeObjectIdClass);
                    tr.setAttribute('ObjectId', item.objectid);
                }

                Object.entries(headerMap).forEach(([header, key]) => {
                    const td = document.createElement('td');
                    if (header === 'APN') {
                        const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        a.setAttribute('data-type', 'apn');
                        td.appendChild(a);
                    } else if (header === 'Name' && (searchQuery === 'pc' || searchQuery === 'pc-' || searchQuery === 'pc-000')) {
                        const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        a.setAttribute('data-type', 'pc-name');
                        td.appendChild(a);
                    } else if (header === 'Username' && filter === 'byPersons') {
                        const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        a.setAttribute('data-type', 'person-username');
                        td.appendChild(a);

                    } else {
                        td.textContent = item[key] != null ? item[key] : '';
                    }
                    tr.appendChild(td);
                });

                resultsBody.appendChild(tr);
            });

            resultsTable.DataTable({
                paging: false,
                info: false,
                lengthChange: false,
                ordering: false
            });
        }

        function renderNoResults() {
            resultsTable.hide();
            noResultsDiv.style.display = 'block'; 

            resultsBody.innerHTML = '';
            tableHeaderRow.innerHTML = '';

            const headers = ["APN", "Name", "SuperType", "Type", "Description", "CreatedDate", "Owner", "Email"];
            headers.forEach(header => {
                const th = document.createElement('th');
                th.textContent = header;
                tableHeaderRow.appendChild(th);
            });
        }
        document.body.addEventListener('click', function(e) {
            if (e.target && e.target.classList.contains('apn-link')) {
                e.preventDefault();
                e.stopPropagation();
                selectedObjectId = e.target.getAttribute('ObjectId');
                if (!selectedObjectId) return;

                // Show context menu at mouse position
                contextMenu.style.top = e.pageY + 'px';
                contextMenu.style.left = e.pageX + 'px';
                contextMenu.style.display = 'block';

                // Store selected id and type for use on menu click
                contextMenu.setAttribute('data-selected-objectid', selectedObjectId);
                contextMenu.setAttribute('data-selected-type', e.target.getAttribute('data-type'));
            } else if (!contextMenu.contains(e.target)) {
                contextMenu.style.display = 'none';
            }
        });

        document.getElementById('openMenuItem').addEventListener('click', function() {
            contextMenu.style.display = 'none';
            const objectId = contextMenu.getAttribute('data-selected-objectid');
            const type = contextMenu.getAttribute('data-selected-type');
            if (!objectId) return;
            let propertiesUrl = '';
            if (type === 'apn') {
                propertiesUrl = '/andromeda/Properties.jsp?name=' + encodeURIComponent(objectId);
            } else if (type === 'pc-name') {
                propertiesUrl = '/andromeda/Partcontroldetails.jsp?name=' + encodeURIComponent(objectId);
            } else if (type === 'person-username') {
                propertiesUrl = '/andromeda/PersonProperties.jsp?name=' + encodeURIComponent(objectId);
            } else {
                propertiesUrl = '/andromeda/Properties.jsp?name=' + encodeURIComponent(objectId);
            }

            window.location.href = propertiesUrl;
        });
    });
</script>
</body>
</html>
