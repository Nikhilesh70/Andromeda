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
<title>Part Control Details</title>
<style>
  body {
    font-family: Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }
  .topbar {
    display: flex;
    background: #f5f7fa;
    border-bottom: 1px solid #cfd3db;
    padding: 6px 12px;
    font-size: 13px;
    color: #333;
  }

  .topbar > div {
    display: flex;
    align-items: center;
    padding: 6px 12px;
    background: #f9fbfd;
    border: 1px solid #cfd3db;
    border-right: none;
    white-space: nowrap;
  }

  .topbar > div:last-child {
    border-right: 1px solid #cfd3db;
  }

  .folder-box {
    background: #e3e7eb;
    border: 1px solid #d1d6dc;
    width: 28px;
    height: 28px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-right: 8px;
    flex-shrink: 0;
  }

  .folder-box img {
    width: 16px;
    height: 16px;
  }

  .part-number {
    font-weight: 700;
    font-size: 14px;
    padding-right: 13px;
    padding-left:13px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  .description {
    font-weight: 600;
    font-size: 13px;
    color: #555;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  .state-box {
    font-weight: 600;
    font-size: 13px;
    color: #333;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
  }

  .state-label {
    margin-right: 4px;
  }

  .btn-submit {
    background-color: #5c8bff;
    border: 1px solid #3f70ff;
    color: white;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-submit:hover {
    background-color: #3f70ff;
  }

  .btn-evaluate {
    background-color: #e5e7ea;
    border: 1px solid #c6cad2;
    color: #555;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-evaluate:hover {
    background-color: #c6cad2;
  }

  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }

  .info-box strong {
    color: #444;
  }

  .topbar > div:not(:last-child) {
    margin-right: -1px; /
  }
	
	.vertical-line img {
  height: 20px;  
  width: 1px;   
  margin: 0 10px; 
}

  .container {
    display: flex;
    height: calc(100vh - 56px); 
    font-size: 13px;
  }

.sidebar {
  width: 16%;
  background-color: #f8f9fa;
  border-right: 1px solid #ddd;
  padding: 20px;
  font-size: 14px;
  box-sizing: border-box;
   resize: horizontal;
  overflow-y: auto;
  overflow-x: hidden; 
}

.sidebar a {
  display: block;
  padding: 8px;
  color: #333;
  text-decoration: none;
  margin-bottom: 10px;
  border-radius: 4px;
}

.sidebar a:hover {
  background-color: #e3e7ea; 
}

.sidebar a.active {
  background-color:#808080;
  color: white;
   font-weight: bold;
}

.main-panel {
  flex-grow: 1;
  padding: 20px;
  overflow-y: auto;
  font-size: 13px;
  box-sizing: border-box;
}


.container {
  display: flex;
  height: calc(100vh - 56px); 
}

.topbar {
  display: flex;
  background: #f5f7fa;
  border-bottom: 1px solid #cfd3db;
  padding: 6px 12px;
  font-size: 13px;
  color: #333;
}

  .toolbar {
    margin-bottom: 5px;
    padding-left: 2px;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    margin-right: 6px;
    vertical-align: middle;
    padding: 2px 4px;
  }
  .toolbar button img {
    vertical-align: middle;
    width: 20px;
    height: 20px;
  }
  .toolbar button:hover {
    background-color: #e3f2fd;
    border-radius: 2px;
  }

table.properties {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: Arial, sans-serif;
  margin: 0 auto;
}

table.properties th,
table.properties td {
  padding: 12px 16px;
  border: 1px solid #ddd; 
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 200px; 
  text-align: left;
}

  .folder-icon {
    width: 16px;
    height: 16px;
    vertical-align: middle;
    margin-right: 6px;
  }

.properties-container {
  max-height: 600px; 
  overflow-y: auto;
  border: 1px solid #ddd;
  margin-top: 0;
}

  #loadingSpinner {
    display: none;
    position: fixed;
    top: 10px;
    right: 10px;
    font-size: 14px;
    color: #666;
  }

  
  #errorMessage {
    display: none;
    color: red;
    margin: 10px 0;
    font-weight: bold;
  }

  #editPanel {
  display: none; 
  position: fixed;
  top: 60px;
  right: 20px;
  width: 320px;
  max-height: 80vh;          
  overflow-y: auto;         
  background: #f9fbfd;
  border: 1px solid #cfd3db;
  padding: 15px 15px 50px 15px; 
  box-shadow: 2px 2px 12px rgba(0,0,0,0.15);
  z-index: 1000;
}

  #editPanel.active {
    display: block;
  }

  #editPanel .mb-3 {
    margin-bottom: 10px;
  }

  #editPanel label {
    font-weight: 600;
    margin-bottom: 4px;
    display: block;
  }

  #editPanel input {
    width: 100%;
    padding: 6px 8px;
    border: 1px solid #ccc;
    border-radius: 3px;
  }

  #editPanel button {
    margin-right: 10px;
    padding: 6px 14px;
    font-size: 13px;
    border-radius: 3px;
    cursor: pointer;
  }

  #saveBtn {
    background-color: #5c8bff;
    border: 1px solid #3f70ff;
    color: white;
  }

  #saveBtn:hover {
    background-color: #3f70ff;
  }

  #cancelBtn {
    background-color: #e5e7ea;
    border: 1px solid #c6cad2;
    color: #555;
  }
  #cancelBtn:hover {
    background-color: #c6cad2;
  }
  .state-box .state-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 13px;
  color: white;
  margin-left: 8px;
  user-select: none;
  text-transform: uppercase;
  min-width: 80px;
  text-align: center;
}
.state-badge.InWork {
  background-color: #5bc0de;
}

.state-badge.InApproval {
  background-color: #6c757d;
}

.state-badge.Completed {
  background-color: #28a745;
}

.state-badge.Cancelled {
  background-color: #000000;
  color: #ffffff;
}
  
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<div class="topbar">
  <div class="left-section">
    <div class="image-box">
      <img src="https://img.icons8.com/?size=50&id=WECphWgmeM0g&format=png&color=000000" alt="Folder Icon" />
    </div>
    <div class="part-info">
      <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
      <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px; padding-left:13px;"></div>
    </div>
    <div class="vertical-line"></div>
  </div>
  <div class="right-section">
    <div class="state-box">
      <span class="state-label">State:</span>
    </div>
    <div class="vertical-line"></div>
    <div class="info-box">
    </div>
    <div class="vertical-line"></div>
  </div>
</div>
<div class="container">
  <div class="sidebar">
        <a href="Partcontroldetails.jsp" class="nav-link active" data-page="Partcontroldetails.jsp">PC-Properties</a>
        <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a>
        <a class="nav-link" href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>">LifeCycle</a>
        <a class="nav-link" href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>">Part Management</a>
</div>

  <div class="main-panel">
    <div class="toolbar">
      <button id="editBtn" title="Edit">
        <img src="edit.gif" alt="Edit" />
      </button>
      <button title="History"></button>
      <button id="refreshBtn" title="Refresh">
        <img src="icons8-refresh.gif" alt="Refresh" />
      </button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
    <table id="detailsTable" class="properties"></table>
  </div>
</div>
    <!-- Edit Side Panel -->
    <div id="editPanel">
        <h5>Edit Part Details</h5>
        <form id="editForm"></form>
        <div class="mt-3">
            <button id="saveBtn" type="button" class="btn btn-primary me-2">Save</button>
            <button id="cancelBtn" type="button" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
    <!-- JS Libraries -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

 <script>
let currentPartData = {};
let loggedInUserAccess = 'admin';  

$(document).ready(function () {
  const objectId = getQueryParam('name') || '';

  if (!objectId) {
    showError("No 'name' (ObjectId) parameter found in the URL.");
    return;
  }

  showLoading(true);

  $.ajax({
    url: 'http://localhost:8080/andromeda/api/datafetchservice/getinfospc',
    method: 'GET',
    data: { objectId: objectId }, 
    dataType: 'json',
    success: function (data) {
      console.log("API Response:", data);

      if (!data || $.isEmptyObject(data)) {
        showError("No details found for ObjectId: " + objectId);
        return;
      }

      currentPartData = data;
      sessionStorage.setItem('partInfo', JSON.stringify(data));
      populateTopBar(data);
      populateTable(data);

      if (loggedInUserAccess.toLowerCase() === 'admin' || loggedInUserAccess.toLowerCase() === 'leader') {
        $('#editBtn').show();
      } else {
        $('#editBtn').hide();
      }
    },
    error: function (xhr) {
      console.error(" AJAX Error:", xhr);
      showError("Error fetching part details.");
    },
    complete: function () {
      showLoading(false);
    }
  });

  $('#editBtn').on('click', function () {
    if (!$.isEmptyObject(currentPartData)) {
      openEditPanel(currentPartData);
    } else {
      alert("Data not loaded yet.");
    }
  });

  $('#cancelBtn').on('click', closeEditPanel);

  $('#saveBtn').on('click', function () {
    const descriptionValue = $('[name="description"]').val();

    if (!descriptionValue || descriptionValue.trim() === '') {
      alert("Description cannot be empty.");
      return;
    }

    const updatedData = {
      description: descriptionValue
    };

    $.ajax({
      url: 'http://localhost:8080/andromeda/api/datafetchservice/updatepartcontrol/' + encodeURIComponent(objectId),
      method: 'PUT',
      contentType: 'application/json',
      data: JSON.stringify(updatedData),
      success: function () {
        alert("Part updated successfully!");
        location.reload();
      },
      error: function (xhr) {
        let msg = "Failed to update part.";
        try {
          const errResp = JSON.parse(xhr.responseText);
          if (errResp.Message) msg = errResp.Message;
        } catch (e) {}
        alert(msg);
      }
    });

    closeEditPanel();
  });

  $('#refreshBtn').on('click', function () {
    location.reload();
  });

  function populateTopBar(data) {
    $('.part-number').text(data.name || '');
    $('.part-type').text(data.type || '');
    $('.part-owner').text(data.owner || '');
    $('.part-created').text(data.createddate || '');
    $('.state-box .state-label').remove();
    if (data.currentstate) {
	    $('.state-box .state-label').remove();
	    const state = data.currentstate;
	    const badge = $('<span>')
	        .addClass('state-badge ' + state.replace(/\s/g, ''))
	        .text(state);
	    $('<span>')
	        .addClass('state-label')
	        .text('State: ')
	        .append(badge)
	        .prependTo('.state-box');
	}
  }
  function populateTable(part) {
    const table = $('#detailsTable');
    table.empty();
    $('#errorMessage').hide();
    $('#detailsTable').show();

    if (part.name) {
      const nameRow = $('<tr>');
      nameRow.append($('<th>').text("Name"));
      nameRow.append($('<td>').text(part.name ?? ''));
      table.append(nameRow);
    }

    const excludedKeys = ['fts_document', 'objectid', 'historyList', 'connectionid', 'linkedobjectid', 'name'];

    for (const key in part) {
      if (!part.hasOwnProperty(key)) continue;
      if (excludedKeys.includes(key.toLowerCase())) continue;
      if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) {
          continue;
      }
      const row = $('<tr>');
      row.append($('<th>').text(prettyLabel(key.toLowerCase())));
      row.append($('<td>').text(part[key] ?? 'N/A'));
      table.append(row);
    }
  }

  function openEditPanel(part) {
    const form = $('#editForm');
    form.empty();

    const editableFields = ['description'];

    for (const key in part) {
      if (!part.hasOwnProperty(key)) continue;
      if (['objectid', 'historyList', 'fts_document', 'connectionid', 'linkedobjectid', 'name'].includes(key)) continue;
      if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) {
          continue;
      }
      const rawValue = part[key] ?? '';
      const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
      const lowerKey = key.toLowerCase();
      const label = prettyLabel(lowerKey);
      const isEditable = editableFields.includes(lowerKey);

      const formGroup = $('<div class="mb-3"></div>');
      const labelEl = $('<label></label>').addClass('form-label').attr('for', safeId).text(label);
      const inputEl = $('<input>')
        .attr('type', 'text')
        .addClass('form-control')
        .attr('id', safeId)
        .attr('name', lowerKey)
        .val(rawValue);

      if (!isEditable) {
        inputEl.attr('readonly', true);
      }

      formGroup.append(labelEl);
      formGroup.append(inputEl);
      form.append(formGroup);
    }

    $('#editPanel').addClass('active');
  }

  function closeEditPanel() {
    $('#editPanel').removeClass('active');
  }

  function getQueryParam(param) {
    return new URLSearchParams(window.location.search).get(param);
  }

  function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
  }

  function showError(msg) {
    $('#errorMessage').text(msg).show();
    $('#detailsTable').hide();
    showLoading(false);
  }

  function prettyLabel(key) {
    const map = {
      description: "Description",
      supertype: "Supertype",
      type: "Type",
      owner: "Owner",
      createddate: "Created Date",
      modifieddate: "Modified Date",
      status: "Status",
      version: "Version"
    };
    return map[key] || key.charAt(0).toUpperCase() + key.slice(1);
  }
});
</script>
</body>
</html>
