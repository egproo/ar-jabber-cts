var renderers = {
    user: function(data, type, row) {
        var displayName = data.role > 0 ? data.name : data.jid;
        if (type === 'display') {
            return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
        } else {
            return displayName;
        }
    },

    date: function(data, type, row) {
        if (type === 'display') {
            return new Date(Date.parse(data)).toISOString().replace(/T.*/, '');
        } 
        return data;
    },

    nextPaymentDate: function(data, type, row) {
        if (type === 'display' && data) {
            var nextDate = new Date(Date.parse(data)),
                today = new Date(),
                expiration_date = new Date(),
                nextDateString = nextDate.toISOString().replace(/T.*/, '');

            expiration_date.setDate(expiration_date.getDate() + 3);

            if (nextDate <= today) {
                return '<span class="expired_date">' + nextDateString + '</span>';
            } else if (nextDate <= expiration_date) {
                return '<span class="to_be_expired_date">' + nextDateString + '</span>';
            }
            return nextDateString;
        } else if (!data) {
            return '';
        }
        return data;
    },

    contract: function(data, type, row) {
        if (type === 'display') {
            return "<a href='/rooms/" + data.id + "'>" + data.name.replace(/@conference.syriatalk.biz$/, '') + "</a>";
        }
        return data.name;
    },

    amount: function(data, type, row) {
        if (type === 'display' && data != null) {
            return '$' + data;
        } 
        return data;
    },

    lastPaymentAmount: function(data, type, row) {
        var lastPayment = row.last_payment;
        if (type === 'display' && lastPayment) {
            return "<a href='/money_transfers/" + lastPayment.money_transfer_id + "'>" + renderers.amount(lastPayment.amount, type, row) + "</a>";
        } else if (!lastPayment) {
            return '';
        }
        return renderers.amount(lastPayment.amount, type, row);
    },

    lastPaymentDate: function(data, type, row) {
        var lastPaymentDate = row.last_payment;
        if (type === 'display' && lastPaymentDate) {
            return renderers.date(lastPaymentDate.effective_from, type, row);
        } else if (!lastPaymentDate) {
            return '';
        }
        return renderers.date(lastPaymentDate.effective_from, type, row);
    },

    mtAmount: function(data, type, row) {
        if (type === 'display') {
            return "<a href='/money_transfers/" + row.id + "'>" + renderers.amount(data, type, row) + "</a>";
        }
        return renderers.amount(data, type, row);
    },

    modelText: function(data, type, row) {
        if (type === 'display') {
            return "<a href='" + data + "'>" + row.changes.replace(/\n/g, "<br/>") + "</a>";
        }
        return data;
    },

    owner: function(data, type, row) {
        if (type === 'display' && row.owner) {
            return "<a href='/users/" + row.owner.id + "'>" + row.owner.name + "</a>";
        } else if (!row.owner) {
            return '';
        }
        return row.owner.name;
    },

    showDateTime: function(date) {
        function addLeadingZero(num) {
            return num < 10 ? '0' + num : num;
        }
        var currDate = new Date(Date.parse(date)),
            currYear = currDate.getFullYear(),
            currMonth = addLeadingZero(currDate.getMonth() + 1),
            currDay = addLeadingZero(currDate.getDate()),
            currHour = addLeadingZero(currDate.getHours()),
            currMin = addLeadingZero(currDate.getMinutes()),
            currSec = addLeadingZero(currDate.getSeconds());
        return currYear + '-' + currMonth + '-' + currDay + ' ' + currHour + ':' + currMin + ':' + currSec;
    },

    dateTime: function(data, type, row) {
        if (type === 'display') {
            return renderers.showDateTime(data);
        }
        return renderers.date(data, type, row);
    }
}
