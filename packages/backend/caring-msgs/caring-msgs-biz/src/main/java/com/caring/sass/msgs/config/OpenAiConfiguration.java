package com.caring.sass.msgs.config;

import com.caring.sass.common.constant.ApplicationProperties;
import com.caring.sass.msgs.bot.service.CaringOpenAiService;
import com.unfbx.chatgpt.OpenAiClient;
import com.unfbx.chatgpt.OpenAiStreamClient;
import com.unfbx.chatgpt.function.KeyRandomStrategy;
import com.unfbx.chatgpt.interceptor.OpenAILogger;
import lombok.extern.slf4j.Slf4j;
import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * @author leizhi
 */
@Slf4j
@Configuration
public class OpenAiConfiguration {

    private final ApplicationProperties applicationProperties;

    public OpenAiConfiguration(ApplicationProperties applicationProperties) {
        this.applicationProperties = applicationProperties;
    }

    @Bean
    public CaringOpenAiService openAiService() {
        List<String> tokens = ApplicationProperties.getOpenAiToken();
        if (tokens == null || tokens.isEmpty()) {
            // 未配置 OpenAI token（如本地/演示环境）时降级为占位 token，
            // 避免因 get(0) 抛 NPE 导致整个 msgs 服务无法启动。
            // 实际调用 AI 接口时会因 token 无效而失败，但不影响其它业务功能。
            log.warn("未配置 caring.application.open-ai-token，OpenAI 服务将使用占位 token，AI 相关功能不可用");
            return new CaringOpenAiService("unconfigured-openai-token", Duration.ofSeconds((120)));
        }
        String token = tokens.get(0);
        return new CaringOpenAiService(token, Duration.ofSeconds((120)));
    }

    @Bean
    public OpenAiStreamClient openAiStreamClient() {
        //本地开发需要配置代理地址
        HttpLoggingInterceptor httpLoggingInterceptor = new HttpLoggingInterceptor(new OpenAILogger());
        //!!!!!!测试或者发布到服务器千万不要配置Level == BODY!!!!
        httpLoggingInterceptor.setLevel(HttpLoggingInterceptor.Level.HEADERS);
        OkHttpClient okHttpClient = new OkHttpClient
                .Builder()
                .addInterceptor(httpLoggingInterceptor)
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(600, TimeUnit.SECONDS)
                .readTimeout(600, TimeUnit.SECONDS)
                .build();

        return OpenAiStreamClient
                .builder()
                .apiHost(ApplicationProperties.getOpenAiHost())
                .apiKey(openAiKeys())
                //自定义key使用策略 默认随机策略
                .keyStrategy(new KeyRandomStrategy())
                .okHttpClient(okHttpClient)
                .build();
    }

    @Bean
    public OpenAiClient openAiClient() {
        //本地开发需要配置代理地址
        HttpLoggingInterceptor httpLoggingInterceptor = new HttpLoggingInterceptor(new OpenAILogger());
        //!!!!!!测试或者发布到服务器千万不要配置Level == BODY!!!!
        httpLoggingInterceptor.setLevel(HttpLoggingInterceptor.Level.HEADERS);
        OkHttpClient okHttpClient = new OkHttpClient
                .Builder()
                .addInterceptor(httpLoggingInterceptor)
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(600, TimeUnit.SECONDS)
                .readTimeout(600, TimeUnit.SECONDS)
                .build();

        return OpenAiClient
                .builder()
                .apiHost(ApplicationProperties.getOpenAiHost())
                .apiKey(openAiKeys())
                //自定义key使用策略 默认随机策略
                .keyStrategy(new KeyRandomStrategy())
                .okHttpClient(okHttpClient)
                .build();
    }

    /**
     * 获取 OpenAI api key 列表；未配置时返回占位值，避免 NPE 导致服务无法启动。
     */
    private List<String> openAiKeys() {
        List<String> tokens = ApplicationProperties.getOpenAiToken();
        if (tokens == null || tokens.isEmpty()) {
            log.warn("未配置 caring.application.open-ai-token，OpenAI 客户端将使用占位 token，AI 相关功能不可用");
            return Collections.singletonList("unconfigured-openai-token");
        }
        return tokens;
    }

}
