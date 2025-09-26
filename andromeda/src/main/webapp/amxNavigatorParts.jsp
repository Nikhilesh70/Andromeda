<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Andromeda Parts</title>

  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: white;
      text-wrap-mode: nowrap;
    }

    h1 {
      text-align: center;
      margin-bottom: 30px;
    }

    .container {
      width: 100%;
      margin: auto;
    }

    .error {
      text-align: center;
      margin-top: 20px;
      color: red;
    }

    table.dataTable a {
      color: #007bff;
      text-decoration: none;
      text-wrap-mode: nowrap;
    }

    table.dataTable a:hover {
      text-decoration: underline;
    }
   
 .state-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-weight: 700;
    font-size: 13px;
    color: white;
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
</head>
<body>
  <h1>Andromeda Parts</h1>
  <div class="container">
    <table id="partsTable" class="display" style="width:100%">
      <thead>
        <tr>
         </tr>
      </thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>
<script>
  $(document).ready(function () {
    const desiredHeaders = ['name', 'apn', 'supertype', 'type', 'description', 'createddate', 'owner', 'email', 'currentstate'];

    $.ajax({
      url: 'http://localhost:8080/andromeda/api/datafetchservice/latestparts',
      method: 'GET',
      dataType: 'json',
      success: function (data) {
        if (!Array.isArray(data) || data.length === 0) {
          $('#errorMessage').text('No parts data found.');
          return;
        }

        $('#partsTable thead tr').empty();
        $('#partsTable tbody').empty();

        desiredHeaders.forEach(header => {
          const displayName = header.charAt(0).toUpperCase() + header.slice(1);
          $('#partsTable thead tr').append('<th>' + displayName + '</th>');
        });

        const dtColumns = desiredHeaders.map(field => {
          if (field === 'name') {
            return {
              data: field,
              render: function (data, type, row) {
                return '<a href="Properties.jsp?name=' + encodeURIComponent(row.objectid) + '" class="part-link">' + data + '</a>';
              }
            };
          }
          if (field === 'createddate') {
            return {
              data: field,
              render: function (data) {
                if (!data) return '';
                const date = new Date(data);
                if (isNaN(date.getTime())) return data;
                return date.toLocaleDateString();
              }
            };
          }
          if (field === 'currentstate') {
            return {
              data: field,
              render: function (data) {
                if (!data) return '';
                const stateClass = data.replace(/\s/g, ''); 
                return '<span class="state-badge ' + stateClass + '">' + data + '</span>';
              }
            };
          }
          return {
            data: field,
            defaultContent: ''
          };
        });

        $('#partsTable').DataTable({
          data: data,
          columns: dtColumns,
          paging: false,
          searching: false,
          info: false,
          ordering: true,
          lengthChange: false,
          destroy: true
        });
      },
      error: function (xhr, status, error) {
        console.error('Error fetching parts:', error);
        $('#errorMessage').text('Failed to fetch parts data.');
      }
    });

    $(document).on('click', 'a.part-link', function (e) {
      e.preventDefault();
      const url = $(this).attr('href');
      if (window.parent && window.parent.document) {
        const iframe = window.parent.document.querySelector('iframe[name="contentFrame"]');
        if (iframe) {
          iframe.src = url;
        } else {
          console.warn('Iframe not found in parent window.');
        }
      }
    });
  });
</script>
</body>
</html>
