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
            var nextDate = new Date(Date.parse(data));
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            var nextDateString = nextDate.toISOString().replace(/T.*/, '');
            if (nextDate <= tomorrow) {
                return '<span class="highlight_date">' + nextDateString + '</span>';
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
            return renderers.amount(lastPayment.amount, type, row);
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
        if (type === 'display' && data) {
            return "<a href='/money_transfers/" + row.id + "'>" + renderers.amount(data, type, row) + "</a>";
        }
        return renderers.amount(data, type, row);
    },

    operation: function(data, type, row) {
        return data.split('.');
    },

    operationType: function(data, type, row) {
        return renderers.operation(data, type, row)[1];
    },

    modelType: function(data, type, row) {
        return renderers.operation(data, type, row)[0];
    },

    modelText: function(data, type, row) {
        if (type === 'display' && row.trackable) {
            return "<a href='/" + renderers.modelType(row.key) + 's' + "/" + row.trackable.id + "'>" + row.trackable.to_s + "</a>";
        } else if (!row.trackable) {
            return '';
        }
        return row.trackable.to_s;
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
        var currDate = new Date(Date.parse(date)),
            currYear = currDate.getFullYear(),
            currMonth = currDate.getMonth() < 10 ? '0' + (currDate.getMonth() + 1) : currDate.getMonth() + 1,
            currDay = currDate.getDate() < 10 ? '0' + currDate.getDate() : currDate.getDate(),
            currHour = currDate.getHours() < 10 ? '0' + currDate.getHours() : currDate.getHours(),
            currMin = currDate.getMinutes() < 10 ? '0' + currDate.getMinutes() : currDate.getMinutes(),
            currSec = currDate.getSeconds() < 10 ? '0' + currDate.getSeconds() : currDate.getSeconds();
        return currYear + '-' + currMonth + '-' + currDay + ' ' + currHour + ':' + currMin + ':' + currSec;
    },

    dateTime: function(data, type, row) {
        if (type === 'display') {
            return renderers.showDateTime(data);
        }
        return renderers.date(data, type, row);
    }
}
