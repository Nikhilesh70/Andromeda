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
<title>SpecificationDocumentUpload</title>
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
    padding-right: 12px;
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
    margin-right: -1px; 
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
  width: 19%;
  background-color: #f8f9fa;
  border-right: 1px solid #ddd;
  padding: 20px;
  font-size: 14px;
  box-sizing: border-box;
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
    width: 18px;
    height: 18px;
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
#detailsTable {
   width: 100%;
   border-collapse: collapse;
   margin-top: 10px;
}
th, td {
   border: 1px solid #dee2e6;
   padding: 12px;
   text-align: left;
   font-wrap-mode:nowrap;
}
th {
background-color: #f8f9fa;
width: 200px;
forn-wrap-mode:nowrap;
}
.nav-tabs {
            margin-bottom: 20px;
        }
        .nav-tabs .nav-link.active {
            background-color: #e9ecef;
            font-weight: bold;
        }
        .toolbar {
            background-color: #f8f9fa;
            padding: 6px 10px;
            border: 1px solid #dee2e6;
            border-bottom: none;
            display: flex;
            gap: 10px;
            border-radius: 4px;
            margin-top: 10px;
        }
         #createPanel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100%;
            background: #fff;
            box-shadow: -2px 0 5px rgba(0,0,0,0.3);
            overflow-y: auto;
            transition: right 0.3s ease;
            z-index: 1051;
            padding: 0;
        }
        #createPanel.active {
            right: 0;
        }
        #createPanel iframe {
            border: none;
            width: 100%;
            height: calc(100% - 56px);
        }
         #partControlTable {
        white-space: nowrap;
        text-wrap-mode:nowrap;
    }
  #typeIcon {
  width: 50px;
  height: 50px;
  object-fit: contain; 
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
.state-badge.Frozen {
  background-color: #6c757d;
}
.state-badge.Approved {
  background-color: #28a745;
}
.state-badge.Released {
  background-color: #ffc107;
  color: #000;
} 
</style>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />

 <script>var loggedInUserAccess = '<%= userAccess.trim() %>';</script>
</head>
<body>
<div class="topbar">
     <div class="left-section">
    <div class="image-box">
            <img id="typeIcon" src="" alt="Type Icon" />
      </div>
    <div class="part-info">
      <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
      <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px;"></div>
    </div>
   <div class="vertical-line"></div>
  </div>
    <div class="right-section">
        <div class="state-box">
            <span class="state-label">State:</span>

        </div>
        <div class="vertical-line"></div>
        <div class="info-box"></div>
        <div class="vertical-line"></div>
    </div>
</div>
<div class="container">
    <div class="sidebar">
       <a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>">Part Properties</a>
        <a class="nav-link" href="Parthistory.jsp?name=<%= request.getParameter("name") %>">History</a>
        <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">LifeCycle</a>
        <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>">Control Management</a>
   		<a class="nav-link" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>">PartSpecification</a>
   		<a class="nav-link active" href="SpecificationDocumentUpload.jsp?name=<%=request.getParameter("name") %>">SpecificationDocument</a>
    </div>
   <div class="main-panel">
    <div class="toolbar mt-2">
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Upload file" id="uploadBtn">
            <img src="https://img.icons8.com/?size=450&id=e2tnuDc86xd6&format=png&color=000000" alt="Add" style="width:20px height:20px;">
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Download file" id="downloadBtn">
            <img src="https://img.icons8.com/?size=150&id=0xU3XgGHcgvR&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
        </button>
    </div>
    <input type="file" id="fileInput" style="display: none;" />
    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
  <div class="table-responsive mt-3">
  <table id="documentTable" class="properties">
    <thead>
      <tr>
        <th>Uploaded File List</th>
      </tr>
    </thead>
    <tbody id="documentTableBody"></tbody>
  </table>
</div>
</div>
</div>
<script>
$(document).ready(function () {
    const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));

    if (partInfo) {
        $('.part-number').text(partInfo.name || '');
        $('.part-type').text(partInfo.type || '');

        const icon = (partInfo.type && partInfo.type.toLowerCase() === 'fastener')
            ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000'
            : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';

        $('#typeIcon').attr('src', icon);

        $('.state-box .state-label').remove();
        if (partInfo.currentstate) {
    	    $('.state-box .state-label').remove();
    	    const state = partInfo.currentstate;
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

    loadUploadedFiles();
});

document.getElementById('uploadBtn').addEventListener('click', function () {
    document.getElementById('fileInput').click();
});

document.getElementById('fileInput').addEventListener('change', function (event) {
    const file = event.target.files[0];
    if (!file) return;

    $('#loadingSpinner').text('Uploading...').show();
    $('#errorMessage').hide();

    const reader = new FileReader();
    reader.onload = function (e) {
        const base64Data = e.target.result.split(',')[1]; 

        const urlParams = new URLSearchParams(window.location.search);
        const objectId = urlParams.get('name') || '';

        const payload = JSON.stringify({
            objectid: objectId,
            fileContentBase64: base64Data,
            fileName: file.name,
            fileType: file.type
        });

        $.ajax({
            url: 'http://localhost:8080/andromeda/api/datafetchservice/upload',
            type: 'POST',
            data: payload,
            contentType: 'application/json',
            success: function (response) {
                $('#loadingSpinner').hide();
                if (response.message) {
                    alert(response.message);
                } else if (response.error) {
                    $('#errorMessage').text(response.error).show();
                } else {
                    alert('Upload Completed');
                }
                loadUploadedFiles();
            },
            error: function (xhr, status, error) {
                $('#loadingSpinner').hide();
                $('#errorMessage').text('Upload failed: ' + error).show();
            }
        });
    };

    reader.onerror = function () {
        $('#loadingSpinner').hide();
        $('#errorMessage').text('Failed to read file').show();
    };

    reader.readAsDataURL(file);
});

function loadUploadedFiles() {
    const urlParams = new URLSearchParams(window.location.search);
    const objectId = urlParams.get('name') || '';

    if (!objectId) return;

    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getUploadedFiles?objectid=' + encodeURIComponent(objectId),
        method: 'GET',
        dataType: 'json',
        success: function (data) {
            const tbody = $('#documentTableBody');
            tbody.empty();

            if (Array.isArray(data) && data.length > 0) {
                data.forEach(function (file) {
                    const row = $('<tr></tr>');
                    const link = $('<a></a>').attr('href', '#').text(file.fileName).on('click', function (e) {
                         e.preventDefault();
                          downloadFile(file.fileName);
                        });
                    row.append($('<td></td>').append(link));
                    tbody.append(row);
                });
            } else {
                tbody.append('<tr><td>No files uploaded</td></tr>');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error fetching files:', error);
            $('#errorMessage').text('Failed to fetch files').show();
        }
    });
}

function downloadFile(fileName) {
    const urlParams = new URLSearchParams(window.location.search);
    const objectId = urlParams.get('name') || '';
    if (!objectId || !fileName) return;
    const downloadUrl = 'http://localhost:8080/andromeda/api/datafetchservice/download?objectid='+ encodeURIComponent(objectId) + '&fileName=' + encodeURIComponent(fileName);
    const a = document.createElement('a');
    a.href = downloadUrl;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}
</script>
</body>
</html>
