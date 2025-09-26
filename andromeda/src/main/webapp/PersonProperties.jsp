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
    <title>Person Properties</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet" />

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
            padding: 6px 10px;
            border: 1px solid #dee2e6;
            border-bottom: none;
            display: flex;
            gap: 12px;
            margin-top: 10px;
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
            font-family: Arial, sans-serif;
            font-weight: bold;
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

    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link active">Person Details</a>
        </li>
    </ul>

    <div class="toolbar">
        <button type="button" class="btn btn-sm btn-light" id="editBtn" data-bs-toggle="tooltip" title="Edit" style="display:none;">
            <i class="bi bi-pencil-fill fs-4" style="background: linear-gradient(45deg, #ff6347, #4682b4); -webkit-background-clip: text; color: transparent;"></i>
        </button>
        <button type="button" class="btn btn-sm btn-light" id="refreshBtn" data-bs-toggle="tooltip" title="Refresh">
            <i class="bi bi-arrow-clockwise text-secondary fs-4"></i>
        </button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
    <table id="detailsTable" class="table table-bordered"></table>

    <!-- Slide-In Edit Panel -->
    <div id="editPanel">
        <h5>Edit Person Details</h5>
        <form id="editForm"></form>
        <div class="mt-3">
            <button id="saveBtn" type="button" class="btn btn-primary me-2">Save</button>
            <button id="cancelBtn" type="button" class="btn btn-secondary">Cancel</button>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <script>
        let originalPersonData = {};
        let accessOptions = [];

        $(document).ready(function () {
            const objectId = getQueryParam('name');
            if (!objectId) {
                showError("No 'name' (ObjectId) parameter found in the URL.");
                return;
            }

            showLoading(true);
            $.ajax({
                url: 'http://localhost:8080/andromeda/api/datafetchservice/persons',
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    if (!data || $.isEmptyObject(data)) {
                        showError("No data available.");
                        return;
                    }
                    const person = data.find(p => p.ObjectId === objectId);
                    if (!person) {
                        showError("No person found with ObjectId: " + objectId);
                        return;
                    }
                    originalPersonData = { ...person };
                    populateTable(person);

                    // Show edit button only if Admin
                    if (loggedInUserAccess.trim().toLowerCase() === 'admin') {
                        $('#editBtn').show();
                    }
                },
                error: function () {
                    showError("Error fetching person details.");
                },
                complete: function () {
                    showLoading(false);
                }
            });
            $.ajax({
                url: 'http://localhost:8080/andromeda/api/datafetchservice/personaccess',
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    accessOptions = data || [];
                },
                error: function () {
                    alert('Failed to load access options.');
                }
            });

            $('#editBtn').on('click', function () {
                if (!$.isEmptyObject(originalPersonData)) {
                    openEditPanel(originalPersonData);
                } else {
                    alert("Data not loaded yet.");
                }
            });

            $('#cancelBtn').on('click', closeEditPanel);

            $('#saveBtn').on('click', function () {
                const objectId = getQueryParam('name');
                const updatedData = {};

                $('#editForm').serializeArray().forEach(({ name, value }) => {
                    updatedData[name] = value;
                });

                $.ajax({
                    url: 'http://localhost:8080/andromeda/api/datafetchservice/updatePerson/' + encodeURIComponent(objectId),
                    method: 'PUT',
                    contentType: 'application/json',
                    data: JSON.stringify(updatedData),
                    success: function () {
                        alert('Data updated successfully!');
                        location.reload();
                    },
                    error: function (xhr) {
                        alert('Error updating data: ' + xhr.responseText);
                    }
                });

                closeEditPanel();
            });

            $('#refreshBtn').on('click', function () {
                location.reload();
            });
        });

        function populateTable(person) {
            const table = $('#detailsTable');
            table.empty();
            $('#errorMessage').hide();
            $('#detailsTable').show();

            for (const key in person) {
                if (key === 'ObjectId') continue;
                const row = $('<tr>');
                row.append($('<th>').text(prettyLabel(key.toLowerCase())));
                row.append($('<td>').text(person[key] ?? 'N/A'));
                table.append(row);
            }
        }

        function openEditPanel(person) {
            const form = $('#editForm');
            form.empty();

            const readonlyFields = ['username'];

            for (const key in person) {
                if (!person.hasOwnProperty(key)) continue;
                if (key === 'ObjectId') continue;

                const value = person[key] ?? '';
                const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
                const lowerKey = key.toLowerCase();
                const label = prettyLabel(lowerKey);

                const formGroup = $('<div class="mb-3"></div>');

                const labelEl = $('<label></label>')
                    .addClass('form-label')
                    .attr('for', safeId)
                    .text(label);

                formGroup.append(labelEl);

                if (lowerKey === 'access') {
                    
                    const select = $('<select></select>')
                        .addClass('form-control')
                        .attr({ id: safeId, name: lowerKey });

                    accessOptions.forEach(opt => {
                        const option = $('<option></option>').attr('value', opt).text(opt);
                        if (opt === value) option.attr('selected', true);
                        select.append(option);
                    });

                    if (readonlyFields.includes(lowerKey)) {
                        select.prop('disabled', true);
                    }

                    formGroup.append(select);
                } else {
                 
                    const input = $('<input>')
                        .attr('type', 'text')
                        .addClass('form-control')
                        .attr({ id: safeId, name: lowerKey })
                        .val(value);

                    if (readonlyFields.includes(lowerKey)) {
                        input.prop('readonly', true);
                    }

                    formGroup.append(input);
                }

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
                firstname: "First Name",
                lastname: "Last Name",
                country: "Country",
                username: "Username",
                email: "Email",
                access: "Access",
              
            };
            return map[key] || key.charAt(0).toUpperCase() + key.slice(1);
        }
    </script>
</body>
</html>
