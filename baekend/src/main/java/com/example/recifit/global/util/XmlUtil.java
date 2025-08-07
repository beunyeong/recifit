package com.example.recifit.global.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;

public class XmlUtil {

    private static final XmlMapper xmlMapper = new XmlMapper();

    static {
        xmlMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    public static <T> T fromXml(String xml, Class<T> valueType) {
        try {
            /**
             * <script> 태그 및 <script/> 태그 완전히 제거
             */
            xml = xml.replaceAll("<script.*?>.*?</script>", "")
                    .replaceAll("<script\\s*/>", "");
            xml = xml.trim();
            return xmlMapper.readValue(xml, valueType);
        } catch (JsonProcessingException e) {
            String preview = xml.length() > 200 ? xml.substring(0, 200) + "..." : xml;
            throw new RuntimeException("XML 파싱 실패: " + preview, e);
        }
    }
}