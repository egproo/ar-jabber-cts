function userRenderer (data, type, row) {
  var displayName = data.role > 0 ? data.name : data.jid;
  return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
}

function dateRenderer (data, type, row) {
  return new Date(Date.parse(data)).toLocaleDateString();
};

function paymentRenderer (data, type, row) {
  var nextDate = new Date(Date.parse(data));
  var tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  if (nextDate <= tomorrow) {
    return '<span class="highlight_date">' + nextDate.toLocaleDateString() + '</span>';
  } else {
    return nextDate.toLocaleDateString();
  }
};
