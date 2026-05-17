CREATE OR REPLACE TRIGGER trg_fact_transaction_npl
AFTER INSERT OR UPDATE OR DELETE ON fact_transaction
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO npl_fact_transaction (
            log_id,
            log_date,
            operation_type,
            transaction_id,
            new_account_id,
            new_transaction_date,
            new_transaction_type,
            new_amount,
            changed_by,
            client_identifier
        )
        VALUES (
            seq_npl_fact_transaction.NEXTVAL,
            SYSDATE,
            'INSERT',
            :NEW.transaction_id,
            :NEW.account_id,
            :NEW.transaction_date,
            :NEW.transaction_type,
            :NEW.amount,
            USER,
            SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
        );

    ELSIF UPDATING THEN
        INSERT INTO npl_fact_transaction (
            log_id,
            log_date,
            operation_type,
            transaction_id,
            old_account_id,
            new_account_id,
            old_transaction_date,
            new_transaction_date,
            old_transaction_type,
            new_transaction_type,
            old_amount,
            new_amount,
            changed_by,
            client_identifier
        )
        VALUES (
            seq_npl_fact_transaction.NEXTVAL,
            SYSDATE,
            'UPDATE',
            :OLD.transaction_id,
            :OLD.account_id,
            :NEW.account_id,
            :OLD.transaction_date,
            :NEW.transaction_date,
            :OLD.transaction_type,
            :NEW.transaction_type,
            :OLD.amount,
            :NEW.amount,
            USER,
            SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
        );

    ELSIF DELETING THEN
        INSERT INTO npl_fact_transaction (
            log_id,
            log_date,
            operation_type,
            transaction_id,
            old_account_id,
            old_transaction_date,
            old_transaction_type,
            old_amount,
            changed_by,
            client_identifier
        )
        VALUES (
            seq_npl_fact_transaction.NEXTVAL,
            SYSDATE,
            'DELETE',
            :OLD.transaction_id,
            :OLD.account_id,
            :OLD.transaction_date,
            :OLD.transaction_type,
            :OLD.amount,
            USER,
            SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
        );
    END IF;
END;
/

