package com.careconnect.service;

import com.careconnect.model.forms.*;
import com.careconnect.repository.FormDefinitionRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

/**
 * Loads the JSON form definitions bundled under {@code classpath:forms/},
 * registers/updates them as {@link FormDefinition} rows, resolves the version
 * in effect for each {@link FormType}, and validates submitted field values
 * against a form's declared rules.
 */
@Service
@Transactional
public class FormSchemaService {

    private static final Logger log = LoggerFactory.getLogger(FormSchemaService.class);
    private static final String FORMS_CLASSPATH = "classpath:forms/*.form.json";

    private static final Pattern SSN = Pattern.compile("^\\d{3}-?\\d{2}-?\\d{4}$");
    private static final Pattern EIN = Pattern.compile("^\\d{2}-?\\d{7}$");
    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
    private static final Pattern ROUTING = Pattern.compile("^\\d{9}$");

    private final FormDefinitionRepository repository;
    private final ObjectMapper objectMapper;

    @Autowired
    public FormSchemaService(FormDefinitionRepository repository, ObjectMapper objectMapper) {
        this.repository = repository;
        // Use Spring Boot's pre-configured ObjectMapper (JavaTimeModule registered,
        // FAIL_ON_UNKNOWN_PROPERTIES disabled by default).
        this.objectMapper = objectMapper;
    }

    /** Read every bundled form definition from the classpath. */
    public List<FormSchema> loadBundledSchemas() {
        List<FormSchema> schemas = new ArrayList<>();
        try {
            Resource[] resources = new PathMatchingResourcePatternResolver()
                    .getResources(FORMS_CLASSPATH);
            for (Resource r : resources) {
                try (InputStream in = r.getInputStream()) {
                    schemas.add(objectMapper.readValue(in, FormSchema.class));
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Failed to load bundled form schemas", e);
        }
        return schemas;
    }

    /**
     * Upsert all bundled definitions and mark, per form type, the
     * latest-effective version ACTIVE (others RETIRED).
     */
    public void syncBundledDefinitions() {
        for (FormSchema schema : loadBundledSchemas()) {
            upsert(schema);
        }
        for (FormType type : FormType.values()) {
            List<FormDefinition> defs = repository.findByFormType(type);
            defs.stream()
                .max((a, b) -> a.getEffectiveDate().compareTo(b.getEffectiveDate()))
                .ifPresent(active -> {
                    for (FormDefinition d : defs) {
                        FormDefinition.FormStatus desired = d.getId().equals(active.getId())
                                ? FormDefinition.FormStatus.ACTIVE
                                : FormDefinition.FormStatus.RETIRED;
                        if (d.getStatus() != desired) {
                            d.setStatus(desired);
                            repository.save(d);
                        }
                    }
                });
        }
        log.info("Synced {} form definitions", repository.count());
    }

    private FormDefinition upsert(FormSchema schema) {
        FormDefinition def = repository
                .findByFormTypeAndVersion(schema.getFormType(), schema.getVersion())
                .orElseGet(FormDefinition::new);

        def.setFormType(schema.getFormType());
        def.setVersion(schema.getVersion());
        def.setTitle(schema.getTitle());
        def.setEffectiveDate(schema.getEffectiveDate());
        def.setExpirationDate(schema.getExpirationDate());
        if (schema.getSourceDocument() != null) {
            def.setSourceFormNumber(schema.getSourceDocument().getFormNumber());
            def.setSourceEdition(schema.getSourceDocument().getEdition());
        }
        if (schema.getFileAttachment() != null) {
            def.setFileCategory(schema.getFileAttachment().getCategory());
        }
        def.setSchemaJson(schema);
        if (def.getStatus() == null) {
            def.setStatus(FormDefinition.FormStatus.DRAFT);
        }
        return repository.save(def);
    }

    public Optional<FormDefinition> getActiveDefinition(FormType type) {
        return repository.findFirstByFormTypeAndStatus(type, FormDefinition.FormStatus.ACTIVE);
    }

    /**
     * Find the bundled schema for a form type. When {@code version} is null or
     * blank the first bundled definition for the type is returned; otherwise the
     * matching version is required.
     */
    public Optional<FormSchema> loadBundledSchema(FormType type, String version) {
        return loadBundledSchemas().stream()
                .filter(s -> s.getFormType() == type)
                .filter(s -> version == null || version.isBlank() || version.equals(s.getVersion()))
                .findFirst();
    }

    /**
     * Validate captured values (keyed by "sectionId.fieldId") against a form's
     * required status and declared validation rules. Returns a list of
     * human-readable error messages; an empty list means the submission is valid.
     */
    public List<String> validateSubmission(FormSchema schema, Map<String, Object> values) {
        List<String> errors = new ArrayList<>();
        Map<String, Object> v = values == null ? Map.of() : values;

        for (FormSection section : schema.getSections()) {
            for (FormField field : section.getFields()) {
                String key = section.getId() + "." + field.getId();
                Object raw = v.get(key);
                boolean present = raw != null && !(raw instanceof String s && s.isBlank());

                if (field.isRequired() && !present) {
                    errors.add(label(field) + " is required.");
                    continue;
                }
                if (!present) {
                    continue; // optional & empty: nothing else to check
                }
                applyRules(field, raw, errors);
            }
        }
        return errors;
    }

    private void applyRules(FormField field, Object raw, List<String> errors) {
        String str = String.valueOf(raw);
        if (field.getValidations() == null) {
            return;
        }
        for (ValidationRule rule : field.getValidations()) {
            String msg = rule.getMessage() != null ? rule.getMessage() : defaultMessage(field, rule);
            switch (rule.getType()) {
                case REQUIRED -> { /* handled by presence check above */ }
                case MIN_LENGTH -> { if (str.length() < asInt(rule.getValue())) errors.add(msg); }
                case MAX_LENGTH -> { if (str.length() > asInt(rule.getValue())) errors.add(msg); }
                case MIN -> { if (asDouble(raw) < asDouble(rule.getValue())) errors.add(msg); }
                case MAX -> { if (asDouble(raw) > asDouble(rule.getValue())) errors.add(msg); }
                case PATTERN -> { if (rule.getPattern() != null && !Pattern.compile(rule.getPattern()).matcher(str).matches()) errors.add(msg); }
                case EMAIL -> { if (!EMAIL.matcher(str).matches()) errors.add(msg); }
                case SSN -> { if (!SSN.matcher(str).matches()) errors.add(msg); }
                case EIN -> { if (!EIN.matcher(str).matches()) errors.add(msg); }
                case ROUTING_NUMBER -> { if (!ROUTING.matcher(str).matches() || !validRouting(str)) errors.add(msg); }
                case CHECKED -> { if (!Boolean.parseBoolean(str)) errors.add(msg); }
                case ENUM -> { if (rule.getValue() instanceof List<?> allowed && !allowed.contains(str)) errors.add(msg); }
                case DATE, DATE_RANGE, AGE_MIN, CUSTOM -> { /* delegated to typed/business validators */ }
            }
        }
    }

    /** ABA routing number checksum. */
    private boolean validRouting(String digits) {
        int[] d = digits.chars().map(c -> c - '0').toArray();
        int sum = 3 * (d[0] + d[3] + d[6])
                + 7 * (d[1] + d[4] + d[7])
                + 1 * (d[2] + d[5] + d[8]);
        return sum % 10 == 0;
    }

    private String label(FormField f) { return f.getLabel() != null ? f.getLabel() : f.getId(); }

    private String defaultMessage(FormField field, ValidationRule rule) {
        return label(field) + " failed validation: " + rule.getType();
    }

    private int asInt(Object o) { return (int) asDouble(o); }

    private double asDouble(Object o) {
        if (o instanceof Number n) return n.doubleValue();
        try { return Double.parseDouble(String.valueOf(o)); }
        catch (NumberFormatException e) { return Double.NaN; }
    }
}
