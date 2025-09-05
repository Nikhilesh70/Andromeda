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
    <meta charset="UTF-8">
    <title>Control Management</title>
    
    <!-- Bootstrap & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    
    <!-- DataTables -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css"/>

    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background-color: white;
        }
        .error {
            color: red;
            margin-top: 20px;
            text-align: center;
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
            z-index: 1050;
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
    </style>

    <script>
        var loggedInUserAccess = '<%= userAccess.trim() %>';
    </script>

    <!-- jQuery, Bootstrap JS, DataTables -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
</head>
<body class="container mt-4">

    <!-- Navigation Tabs -->
    <ul class="nav nav-tabs">
        <li class="nav-item"><a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>">Part Properties</a></li>
        <li class="nav-item"><a class="nav-link" href="searchHistory.jsp?name=<%= request.getParameter("name") %>">History</a></li>
        <li class="nav-item"><a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">Lifecycle</a></li>
        <li class="nav-item"><a class="nav-link active" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>">Control Management</a></li>
    </ul>

    <!-- Toolbar -->
    <div class="toolbar mt-2">
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part Control" id="openCreatePanelBtn">
            <i class="bi bi-asterisk fs-6" style="color: #9370DB;"></i>
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Add Existing Part" id="addExistingpart">
       <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
    </button>

    </div>

    <table class="table table-bordered mt-2" id="partControlTable">
        <thead></thead>
        <tbody></tbody>
    </table>

    <div id="errorMessage" class="error"></div>

    <div id="createPanel">
        <iframe id="createIframe" src=""></iframe>
    </div>

<script>

function receiveSelectedParts(selectedParts) {
    if (!selectedParts || selectedParts.length === 0) {
        console.log("No parts selected.");
        return; 
    }
    console.log("Received selected parts:", selectedParts);

    const table = $('#partControlTable').DataTable();

    if (!table) {
        console.log("Table not initialized. Initializing...");
        loadPartControlTable();
        return;
    }

    selectedParts.forEach(part => {
        const columns = table.settings().init().columns;
        const newRowData = columns.map(col => part[col.data] || '');
        table.row.add(newRowData).draw(false);
    });

    $('#errorMessage').text('New parts added.');
}
function loadPartControlTable() {
    $('#errorMessage').text('Loading part controls...');

    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');

    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }

    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getcreatedpartcontrol',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function(data) {
            $('#errorMessage').text('');

            if (!data || data.length === 0 || data.message) {
                $('#errorMessage').text(data.message || 'No part controls found.');
                if ($.fn.DataTable.isDataTable('#partControlTable')) {
                    $('#partControlTable').DataTable().clear().draw();
                }
                return;
            }

            let keys = Object.keys(data[0]);
            const excludeKeys = ['objectid', 'connectionid', 'linkedobjectid','fts_document'];
            keys = keys.filter(k => !excludeKeys.includes(k));

            const columns = keys.map(key => ({
                data: key,
                title: key.charAt(0).toUpperCase() + key.slice(1)
               
            }));

            if ($.fn.DataTable.isDataTable('#partControlTable')) {
                $('#partControlTable').DataTable().destroy();
            }

            $('#partControlTable').DataTable({
                data: data,
                columns: columns,
                order: [[ columns.findIndex(c => c.data === 'createddate') || 0, 'desc' ]],
                responsive: false,
                paging: false,
                searching: false,
                scrollX: true,
                info: false,
                destroy: true
            });
        },
        error: function() {
            $('#errorMessage').text('Failed to load part controls.');
        }
    });
}

    $(document).ready(function() {
        loadPartControlTable();

        document.getElementById('openCreatePanelBtn').addEventListener('click', function () {
            const urlParams = new URLSearchParams(window.location.search);
            const objectid = urlParams.get('name');

            if (objectid) {
                const panel = document.getElementById('createPanel');
                panel.classList.add('active');
                document.getElementById('createIframe').src = 'Partcontrolwithconnection.jsp?name=' + encodeURIComponent(objectid);
            } else {
                alert('No object ID found!');
            }
        });
    });
    
    $('#addExistingpart').on('click', function () {
        const urlParams = new URLSearchParams(window.location.search);
        const objectid = urlParams.get('name');

        if (objectid) {
            const targetUrl = 'search.jsp?name=' + encodeURIComponent(objectid);
            window.open(targetUrl,'AddExistingPartPopup','width=900,height=800, position=center,left=100,top=100,resizable=yes' );
        } else {
            alert('No object ID found!');
        }
    });

    window.addEventListener('message', function (event) {
    	  const action = event.data?.action;
    	  const createPanel = document.getElementById('createPanel');

    	  if (!createPanel) return;

    	  if (action === 'closeOnly') {
    	    createPanel.classList.remove('active');
    	  }

    	  if (action === 'closeAndRefresh') {
    	    createPanel.classList.remove('active');

    	    refreshPartControlList(); 
    	  }
    	});

    function closeCreatePanel() {
        const panel = document.getElementById('createPanel');
        panel.classList.remove('active');
        document.getElementById('createIframe').src = '';
    }


</script>
</body>
</html>
