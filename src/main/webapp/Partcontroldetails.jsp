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
    <meta charset="UTF-8"/>
    <title>PC Properties</title>

    <!-- Bootstrap CSS & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background-color: white;
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
        }
        th {
            background-color: #f8f9fa;
            width: 200px;
        }
        .error {
            color: red;
            margin-top: 20px;
            text-align: center;
        }
        #loadingSpinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 40px auto 10px auto;
            display: none;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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
    padding: 8px 12px;  /* reduced padding */
    border: 1px  solid #ddd;
    border-bottom: none;
    display: flex;
    gap: 10px;          /* reduced gap */
    margin-top: 10px;
    border-radius: 4px;
	}
	.toolbar .btn {
    padding: 2px 6px;
    font-size: 0.8rem; /* smaller font size */
	}

		.toolbar .btn i {
   	 font-size: 1.2rem !important; /* smaller icon size */
		}

        #editPanel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100%;
            background: #fff;
            box-shadow: -2px 0 5px rgba(0,0,0,0.3);
            overflow-y: auto;
            transition: right 0.3s ease;
            z-index: 1050;
            padding: 20px;
            font-family:Arial, sans-serif;
            font-weight:bold;
        }
        #editPanel.active {
            right: 0;
        }
    </style>

    <script>
        var loggedInUserAccess = '<%= userAccess.trim() %>';
    </script>
</head>
<body class="container mt-4">
    <!-- Navigation Tabs -->
    <ul class="nav nav-tabs">
        <li class="nav-item"><a class="nav-link active">PC-Properties</a></li>
        <li class="nav-item"><a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a></li>
        <li class="nav-item"><a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">Lifecycle</a></li>
    <li class="nav-item"><a class="nav-link" href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>">PartManagement</a></li>
    </ul>

    <div class="toolbar">
      <button type="button" class="btn btn-sm btn-light" id="editBtn" data-bs-toggle="tooltip" title="Edit" style="display:none; padding: 2px 6px;">
    <i class="bi bi-pencil-fill" style="color: #32cd32; font-size: 1.2rem;"></i>
	</button>
		<button type="button" class="btn btn-sm btn-light" id="refreshBtn" data-bs-toggle="tooltip" title="Refresh" style="padding: 2px 6px;">
    <i class="bi bi-arrow-clockwise text-secondary" style="font-size: 1.2rem;"></i>
		</button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>

    <table id="detailsTable" class="table table-bordered"></table>

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

        $(document).ready(function () {
            const objectId = getQueryParam('name');
            if (!objectId) {
                showError("No 'name' (ObjectId) parameter found in the URL.");
                return;
            }

            showLoading(true);

            $.ajax({
                url: 'http://localhost:8080/andromeda/api/datafetchservice/getinfospc',
                method: 'GET',
                data: { objectId },
                dataType: 'json',
                success: function (data) {
                    if (!data || $.isEmptyObject(data)) {
                        showError("No details found for ObjectId: " + objectId);
                        return;
                    }
                    currentPartData = data;
                    populateTable(data);
                    if (loggedInUserAccess.toLowerCase() === 'admin' || loggedInUserAccess.toLowerCase() === 'leader') {
                        $('#editBtn').show();
                    }
                },
                error: function () {
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
                const objectId = getQueryParam('name');
                const descriptionValue = $('[name="description"]').val();  

                if (!descriptionValue || descriptionValue.trim() === '') {
                    alert("Description cannot be empty.");
                    return;
                }

                const updatedData = {
                    "description": descriptionValue
                };

                $.ajax({
                    url: 'http://localhost:8080/andromeda/api/datafetchservice/updatepart/' + encodeURIComponent(objectId),
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
        });

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

            const excludedKeys = ['fts_document', 'objectid', 'historyList', 'connectionid','linkedobjectid','name'];

            for (const key in part) {
                if (!part.hasOwnProperty(key)) continue;
                if (excludedKeys.includes(key.toLowerCase())) continue;

                const row = $('<tr>');
                row.append($('<th>').text(prettyLabel(key.toLowerCase())));
                row.append($('<td>').text(part[key] ?? 'N/A'));
                table.append(row);
            }
        }
        function openEditPanel(part) {
            console.log("Opening edit panel with data:", part);  

            const form = $('#editForm');
            form.empty();

            const editableFields = ['description']; 

            for (const key in part) {
                if (!part.hasOwnProperty(key)) continue;
                if (key === 'objectid' || key === 'historyList' || key === 'fts_document' || key === 'connectionid' || key==='linkedobjectid'|| key==='name') continue;
                const rawValue = part[key] ?? '';
                const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
                const lowerKey = key.toLowerCase();
                const label = prettyLabel(lowerKey);

                const isEditable = editableFields.includes(lowerKey);

                console.log(`Adding field: ${key} (label: ${label}), editable: ${isEditable}`);

                const formGroup = $('<div class="mb-3"></div>');

                const labelEl = $('<label></label>')
                    .addClass('form-label')
                    .attr('for', safeId)
                    .text(label);

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
            return map[key] || key;
        }

    </script>
</body>
</html>
